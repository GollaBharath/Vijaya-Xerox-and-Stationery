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
import 'features/checkout/providers/checkout_provider.dart';
import 'features/orders/providers/orders_provider.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize token manager
  final tokenManager = TokenManager();
  await tokenManager.initialize();

  // Create auth provider and initialize
  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(MainApp(tokenManager: tokenManager, authProvider: authProvider));
}

class MainApp extends StatelessWidget {
  final TokenManager tokenManager;
  final AuthProvider authProvider;

  const MainApp({
    super.key,
    required this.tokenManager,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    // Create API client
    final apiClient = ApiClient(
      baseUrl: AppConstants.apiBaseUrl,
      tokenManager: tokenManager,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => CategoryProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SubjectProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ProductProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CartProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CheckoutProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(apiClient)),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Key forces router to rebuild when auth state changes
          return MaterialApp.router(
            key: ValueKey(
              'router_${authProvider.isAuthenticated}_${authProvider.isSplashComplete}',
            ),
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
