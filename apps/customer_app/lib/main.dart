import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'core/config/constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/firebase_auth_provider.dart';
import 'features/catalog/providers/category_provider.dart';
import 'features/catalog/providers/subject_provider.dart';
import 'features/catalog/providers/product_provider.dart';
import 'features/cart/providers/cart_provider.dart';
import 'features/checkout/providers/checkout_provider.dart';
import 'features/orders/providers/orders_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/likes/providers/likes_provider.dart';
import 'features/feedback/providers/feedback_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize token manager
  final tokenManager = TokenManager();
  await tokenManager.initialize();

  // Create API client
  final apiClient = ApiClient(
    baseUrl: AppConstants.apiBaseUrl,
    tokenManager: tokenManager,
  );

  // Create Firebase auth provider and initialize
  final authProvider = FirebaseAuthProvider(apiClient: apiClient);
  await authProvider.initialize();

  // Create notification provider and initialize
  final notificationProvider = NotificationProvider();
  // Initialize notifications after auth is ready
  authProvider.addListener(() {
    if (authProvider.isAuthenticated) {
      notificationProvider.initialize();
    }
  });

  runApp(
    MainApp(
      tokenManager: tokenManager,
      authProvider: authProvider,
      apiClient: apiClient,
      notificationProvider: notificationProvider,
    ),
  );
}

class MainApp extends StatelessWidget {
  final TokenManager tokenManager;
  final FirebaseAuthProvider authProvider;
  final ApiClient apiClient;
  final NotificationProvider notificationProvider;

  const MainApp({
    super.key,
    required this.tokenManager,
    required this.authProvider,
    required this.apiClient,
    required this.notificationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider(create: (_) => CategoryProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => SubjectProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => ProductProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CartProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => CheckoutProvider(apiClient)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(apiClient)),
        ChangeNotifierProvider(
          create: (_) => LikesProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(create: (_) => FeedbackProvider(apiClient)),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(apiClient: apiClient),
        ),
      ],
      child: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, _) {
          // Fetch likes when user authenticates
          if (authProvider.isAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final likesProvider = Provider.of<LikesProvider>(
                context,
                listen: false,
              );
              // Fetch liked products from backend
              likesProvider.fetchLikedProducts();
            });
          }

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
