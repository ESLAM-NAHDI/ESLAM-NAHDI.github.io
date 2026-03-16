import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';
import '../providers/user_provider.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, i) {
              final user = users[i];
              return _UserCard(user: user);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _UserCard extends ConsumerStatefulWidget {
  final AppUser user;

  const _UserCard({required this.user});

  @override
  ConsumerState<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<_UserCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;
    final service = ref.read(userServiceProvider);
    final isDefaultAdmin = service.isDefaultAdmin(user.email);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        leading: CircleAvatar(
          backgroundColor: user.isPending
              ? Colors.orange
              : user.isBlocked
                  ? Colors.red
                  : Colors.green,
          child: Text(
            user.email.isNotEmpty ? user.email[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          user.email,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${user.status}${user.isAdmin ? ' • Admin' : ''}',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: !isDefaultAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.isPending) ...[
                    _ActionButton(
                      label: 'Approve',
                      color: Colors.green,
                      onPressed: () => _approve(user),
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      label: 'Block',
                      color: Colors.red,
                      onPressed: () => _block(user),
                    ),
                  ] else if (user.isApproved) ...[
                    _ActionButton(
                      label: 'Block',
                      color: Colors.red,
                      onPressed: () => _block(user),
                    ),
                  ] else if (user.isBlocked) ...[
                    _ActionButton(
                      label: 'Approve',
                      color: Colors.green,
                      onPressed: () => _approve(user),
                    ),
                  ],
                ],
              )
            : null,
        children: [
          if (!isDefaultAdmin) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Permissions',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...PermissionKeys.all.map((key) => SwitchListTile(
                            title: Text(PermissionKeys.label(key)),
                            value: user.permissions[key] ?? false,
                            onChanged: (v) => _updatePermission(user, key, v),
                          )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _approve(AppUser user) async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;
    try {
      await ref.read(userServiceProvider).approveUser(user.uid, authUser.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text('${user.email} approved', style: const TextStyle(color: Colors.white)),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _block(AppUser user) async {
    try {
      await ref.read(userServiceProvider).blockUser(user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text('${user.email} blocked', style: const TextStyle(color: Colors.white)),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updatePermission(AppUser user, String key, bool value) async {
    final perms = Map<String, bool>.from(user.permissions);
    perms[key] = value;
    try {
      await ref.read(userServiceProvider).updatePermissions(user.uid, perms);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('Permission updated', style: TextStyle(color: Colors.white))),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
      ),
      child: Text(label),
    );
  }
}
