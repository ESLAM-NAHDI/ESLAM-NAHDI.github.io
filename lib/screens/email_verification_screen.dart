import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'login_screen.dart';
import 'pending_approval_screen.dart';
import '../main.dart';
import '../models/app_user.dart';
import '../services/user_service.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _isChecking = false;
  bool _isResending = false;

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isChecking = false);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }

    // Force refresh from server - reload user and get fresh token
    await user.reload();
    await user.getIdToken(true);
    final updatedUser = FirebaseAuth.instance.currentUser;
    final isVerified = updatedUser?.emailVerified ?? false;

    if (mounted) {
      setState(() => _isChecking = false);
      if (isVerified) {
        final service = ref.read(userServiceProvider);
        if (service.isDefaultAdmin(updatedUser?.email)) {
          await _ensureAdminUser(updatedUser!);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          final appUser = await service.getUser(updatedUser!.uid);
          if (appUser?.isApproved ?? false) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => PendingApprovalScreen(email: updatedUser.email ?? widget.email),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Email not verified yet. Please check your inbox (and spam folder) and click the verification link.',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _ensureAdminUser(dynamic firebaseUser) async {
    final service = ref.read(userServiceProvider);
    final existing = await service.getUser(firebaseUser.uid);
    if (existing == null || !existing.isAdmin) {
      await service.createOrUpdateUser(AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        status: 'approved',
        isAdmin: true,
        permissions: {for (final k in PermissionKeys.all) k: true},
        createdAt: existing?.createdAt ?? DateTime.now(),
      ));
    }
  }

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Verification email sent! Check your inbox.', style: const TextStyle(color: Colors.white))),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) setState(() => _isResending = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/ic_nahdi.svg', width: 100, height: 100),
                const SizedBox(height: 32),
                Icon(Icons.mark_email_unread_outlined, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Verify your email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a verification link to',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Click the link in the email to verify your account, then tap below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'If you don\'t see the email, check your spam/junk folder.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.error.withOpacity(0.9),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _checkVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('I\'ve verified my email'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isResending ? null : _resendVerification,
                  child: _isResending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Resend verification email'),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  child: const Text('Back to Sign In'),
                ),
                const SizedBox(height: 32),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'v${snapshot.data!.version}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
