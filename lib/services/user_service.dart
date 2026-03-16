import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';

const defaultAdminEmail = 'Rafat.EW@sakhaa.sa';

final userServiceProvider = Provider<UserService>((ref) => UserService());

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isDefaultAdmin(String? email) =>
      email != null && email.toLowerCase() == defaultAdminEmail.toLowerCase();

  Future<AppUser?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromFirestore(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return null;
  }

  Future<void> createOrUpdateUser(AppUser user) async {
    try {
      final data = user.toFirestore();
      data['createdAt'] = user.createdAt != null
          ? Timestamp.fromDate(user.createdAt!)
          : FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(user.uid).set(data, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  Future<void> approveUser(String uid, String approvedByUid) async {
    await _firestore.collection('users').doc(uid).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': approvedByUid,
      'updatedAt': FieldValue.serverTimestamp(),
      'permissions': {
        PermissionKeys.apiDashboard: true,
        PermissionKeys.nahdiMan: true,
        PermissionKeys.pages: true,
        PermissionKeys.developerNotes: true,
        PermissionKeys.migration: false,
        PermissionKeys.admin: false,
      },
    });
  }

  Future<void> blockUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'status': 'blocked',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePermissions(String uid, Map<String, bool> permissions) async {
    await _firestore.collection('users').doc(uid).update({
      'permissions': permissions,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppUser>> watchAllUsers() {
    return _firestore.collection('users').snapshots().map(
          (snap) {
            final list = snap.docs
                .map((d) => AppUser.fromFirestore(d.data(), d.id))
                .toList();
            list.sort((a, b) {
              final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
              final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
              return bTime.compareTo(aTime);
            });
            return list;
          },
        );
  }
}
