import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config/constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../routing/route_names.dart';
import '../../../core/providers/branding_provider.dart';
import '../providers/firebase_auth_provider.dart';

/// Splash screen that checks authentication and redirects
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = context.read<FirebaseAuthProvider>();

    // Initialize auth provider (load from storage, etc.)
    await authProvider.initialize();

    if (!mounted) return;

    // Small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Navigate based on auth state
    if (authProvider.isAuthenticated) {
      context.go(RouteNames.home);
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final branding = context.watch<BrandingProvider>();
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Branding
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _getInitials(branding.companyName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App name
            Text(branding.companyName, style: AppTypography.heading2),
            const SizedBox(height: 8),

            // Tagline
            Text(
              branding.tagline,
              style: AppTypography.body2.copyWith(color: AppColors.hintText),
            ),
            const SizedBox(height: 40),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  /// Generate up to 2-character initials from a name
  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'CN';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
