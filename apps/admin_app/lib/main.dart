import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/config/env.dart';
import 'routing/app_router.dart';
import 'routing/route_names.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/category_management/providers/category_provider.dart';
import 'features/subject_management/providers/subject_provider.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment configuration
  if (!Env.isValid()) {
    throw Exception('Invalid environment configuration');
  }

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Dashboard provider
        ChangeNotifierProvider(create: (_) => DashboardProvider()),

        // Category management provider
        ChangeNotifierProvider(create: (_) => CategoryProvider()),

        // Subject management provider
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
      ],
      child: MaterialApp(
        title: Env.appName,
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // Routing
        initialRoute: RouteNames.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
