import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/config/env.dart';
import 'routing/app_router.dart';
import 'routing/route_names.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/category_management/providers/category_provider.dart';
import 'features/subject_management/providers/subject_provider.dart';
import 'features/user_management/providers/user_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/product_management/providers/product_provider.dart';
import 'features/product_management/providers/variant_provider.dart';
import 'features/order_management/providers/order_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'core/services/notification_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment configuration
  if (!Env.isValid()) {
    throw Exception('Invalid environment configuration');
  }

  // Initialize Firebase (optional - app will work without it)
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp();
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('App will continue without Firebase features');
  }

  // Initialize TokenManager before creating any providers
  final tokenManager = TokenManager();
  await tokenManager.initialize();

  // Initialize notification service only if Firebase is available
  if (firebaseInitialized) {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();
    } catch (e) {
      debugPrint('Notification service initialization error: $e');
    }
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

        // User management provider
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // Settings provider
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // Product management providers
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => VariantProvider()),

        // Order management provider
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        
        // Notification provider
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
