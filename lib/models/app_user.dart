/// App user with approval status and permissions
class AppUser {
  final String uid;
  final String email;
  final String status; // 'pending' | 'approved' | 'blocked'
  final bool isAdmin;
  final Map<String, bool> permissions;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  const AppUser({
    required this.uid,
    required this.email,
    this.status = 'pending',
    this.isAdmin = false,
    this.permissions = const {},
    this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  bool get isApproved => status == 'approved';
  bool get isBlocked => status == 'blocked';
  bool get isPending => status == 'pending';

  bool hasPermission(String key) {
    if (isAdmin) return true;
    return permissions[key] ?? false;
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? status,
    bool? isAdmin,
    Map<String, bool>? permissions,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    final perms = data['permissions'] as Map<String, dynamic>?;
    final permMap = perms != null
        ? perms.map((k, v) => MapEntry(k.toString(), v == true))
        : <String, bool>{};
    return AppUser(
      uid: id,
      email: data['email'] ?? '',
      status: data['status'] ?? 'pending',
      isAdmin: data['isAdmin'] == true,
      permissions: permMap,
      createdAt: (data['createdAt'] as dynamic)?.toDate(),
      approvedAt: (data['approvedAt'] as dynamic)?.toDate(),
      approvedBy: data['approvedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'status': status,
      'isAdmin': isAdmin,
      'permissions': permissions,
      'approvedAt': approvedAt,
      'approvedBy': approvedBy,
    };
  }
}

/// Permission keys for each tab/section
class PermissionKeys {
  static const apiDashboard = 'apiDashboard';
  static const nahdiMan = 'nahdiMan';
  static const pages = 'pages';
  static const developerNotes = 'developerNotes';
  static const migration = 'migration';
  static const admin = 'admin';

  static const all = [
    apiDashboard,
    nahdiMan,
    pages,
    developerNotes,
    migration,
    admin,
  ];

  static String label(String key) {
    switch (key) {
      case apiDashboard:
        return 'API Dashboard';
      case nahdiMan:
        return 'Nahdi Man';
      case pages:
        return 'Pages (Screen Docs)';
      case developerNotes:
        return 'Developer Notes';
      case migration:
        return 'Firebase Migration';
      case admin:
        return 'Admin';
      default:
        return key;
    }
  }
}
