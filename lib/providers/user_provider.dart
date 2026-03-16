import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';
import 'auth_provider.dart';

final currentAppUserProvider = FutureProvider<AppUser?>((ref) async {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  if (authUser == null) return null;

  final service = ref.watch(userServiceProvider);

  if (service.isDefaultAdmin(authUser.email)) {
    return AppUser(
      uid: authUser.uid,
      email: authUser.email ?? '',
      status: 'approved',
      isAdmin: true,
      permissions: {for (final k in PermissionKeys.all) k: true},
    );
  }

  return service.getUser(authUser.uid);
});

final allUsersProvider = StreamProvider<List<AppUser>>((ref) {
  final service = ref.watch(userServiceProvider);
  return service.watchAllUsers();
});
