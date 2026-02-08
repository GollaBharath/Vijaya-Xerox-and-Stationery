import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart' as auth;
import '../features/auth/screens/login_screen.dart' as auth;
import '../features/auth/screens/register_screen.dart' as auth;
import '../features/catalog/screens/catalog_screen.dart';
import '../features/catalog/screens/product_detail_screen.dart';
import '../features/cart/screens/cart_screen.dart';
import '../features/checkout/screens/address_screen.dart';
import '../features/checkout/screens/confirmation_screen.dart';
import '../features/orders/screens/orders_list_screen.dart';
import '../features/orders/screens/order_detail_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/search/screens/search_screen.dart';
import 'route_names.dart';

/// Application router configuration using GoRouter
class AppRouter {
  /// Get the GoRouter instance
  static GoRouter getRouter({
    required bool isAuthenticated,
    required bool isSplashComplete,
  }) {
    return GoRouter(
      initialLocation: _getInitialRoute(isAuthenticated, isSplashComplete),
      redirect: _handleRedirect,
      routes: _buildRoutes(),
      errorBuilder: (context, state) => const ErrorScreen(),
      observers: [GoRouterObserver()],
    );
  }

  /// Determine initial route based on app state
  static String _getInitialRoute(bool isAuthenticated, bool isSplashComplete) {
    if (!isSplashComplete) {
      return RouteNames.splash;
    }
    return isAuthenticated ? RouteNames.home : RouteNames.login;
  }

  /// Handle route redirects
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    // Add redirect logic here if needed (e.g., force login)
    return null;
  }

  /// Build all routes
  static List<RouteBase> _buildRoutes() {
    return [
      // Splash route
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const auth.SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const auth.LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const auth.RegisterScreen(),
      ),

      // Main app shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const CatalogScreen(),
            routes: [
              GoRoute(
                path: 'category/:categoryId',
                builder: (context, state) {
                  final categoryId = state.pathParameters['categoryId']!;
                  return CategoryProductsScreen(categoryId: categoryId);
                },
              ),
              GoRoute(
                path: 'product/:productId',
                builder: (context, state) {
                  final productId = state.pathParameters['productId']!;
                  return ProductDetailScreen(productId: productId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'addresses',
                builder: (context, state) => const AddressesScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddAddressScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:addressId',
                    builder: (context, state) {
                      final addressId = state.pathParameters['addressId']!;
                      return EditAddressScreen(addressId: addressId);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Checkout flow (outside shell)
      GoRoute(
        path: RouteNames.checkout,
        builder: (context, state) => const AddressScreen(),
      ),
      GoRoute(
        path: RouteNames.orderConfirmation,
        builder: (context, state) => const ConfirmationScreen(),
      ),

      // Orders
      GoRoute(
        path: RouteNames.orders,
        builder: (context, state) => const OrdersListScreen(),
        routes: [
          GoRoute(
            path: ':orderId',
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return OrderDetailScreen(orderId: orderId);
            },
          ),
        ],
      ),

      // Search
      GoRoute(
        path: RouteNames.search,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return SearchScreen(initialQuery: query);
        },
      ),

      // Error pages
      GoRoute(
        path: RouteNames.notFound,
        builder: (context, state) => const NotFoundScreen(),
      ),
    ];
  }
}

/// Custom GoRouter observer for logging
class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Add logging if needed
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Add logging if needed
  }
}

// Placeholder screens - these will be implemented later
class CategoryProductsScreen extends StatelessWidget {
  final String categoryId;

  const CategoryProductsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Category: $categoryId')));
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Edit Profile')));
  }
}

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Addresses')));
  }
}

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Add Address')));
  }
}

class EditAddressScreen extends StatelessWidget {
  final String addressId;

  const EditAddressScreen({super.key, required this.addressId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Edit Address: $addressId')));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Settings')));
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('404 Not Found')));
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Error')));
  }
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) {
          final routes = [
            RouteNames.home,
            RouteNames.cart,
            RouteNames.orders,
            RouteNames.profile,
          ];
          context.go(routes[index]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
