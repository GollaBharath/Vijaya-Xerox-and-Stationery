import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import 'app_router.dart';
import 'route_names.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!authProvider.isAuthenticated || !authProvider.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppRouter.pushAndRemoveUntil(context, RouteNames.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
