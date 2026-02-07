import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'core/config/constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/catalog/providers/category_provider.dart';
import 'features/catalog/providers/subject_provider.dart';
import 'features/catalog/providers/product_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize token manager
  final tokenManager = TokenManager();
  await tokenManager.initialize();

  runApp(MainApp(tokenManager: tokenManager));
}

class MainApp extends StatelessWidget {
  final TokenManager tokenManager;

  const MainApp({super.key, required this.tokenManager});

  @override
  Widget build(BuildContext context) {
    // Create API client
    final apiClient = ApiClient(
      baseUrl: AppConstants.apiBaseUrl,
      tokenManager: tokenManager,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SubjectProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ProductProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CartProvider(apiClient)),
      ],
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
