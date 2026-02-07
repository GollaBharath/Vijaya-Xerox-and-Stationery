import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'routing/app_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.getRouter(
              isAuthenticated: authProvider.isAuthenticated,
              isSplashComplete: authProvider.isSplashComplete,
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
