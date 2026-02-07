import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../../../routing/app_router.dart';
import '../providers/auth_provider.dart';

/// Splash screen - checks authentication and redirects appropriately
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
    // Wait a minimum time to show splash screen
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Initialize auth state (checks if user is logged in)
    await authProvider.initialize();

    if (!mounted) return;

    // Navigate based on authentication status
    if (authProvider.isAuthenticated && authProvider.isAdmin) {
      // User is logged in and is admin - go to dashboard
      AppRouter.pushReplacement(context, RouteNames.dashboard);
    } else {
      // User is not logged in or not admin - go to login
      AppRouter.pushReplacement(context, RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon/logo
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),

            // App name
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),

            // Subtitle
            Text(
              'Admin Portal',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textWhite.withAlpha(204),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding * 2),

            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
            ),
          ],
        ),
      ),
    );
  }
}
