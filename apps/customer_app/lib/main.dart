import 'package:flutter/material.dart';
import 'core/config/constants.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final bool _isAuthenticated;
  late final bool _isSplashComplete;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize app - check auth status, load preferences, etc.
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isSplashComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.getRouter(
        isAuthenticated: _isAuthenticated,
        isSplashComplete: _isSplashComplete,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
