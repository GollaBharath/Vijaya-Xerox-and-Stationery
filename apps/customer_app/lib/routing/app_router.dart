import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart' as auth;
import '../features/auth/screens/login_screen.dart' as auth;
import '../features/auth/screens/register_screen.dart' as auth;
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
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.catalog,
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
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: RouteNames.orderConfirmation,
        builder: (context, state) => const OrderConfirmationScreen(),
      ),

      // Orders
      GoRoute(
        path: RouteNames.orders,
        builder: (context, state) => const OrdersScreen(),
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
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchScreen(query: query);
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
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home')));
  }
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Catalog')));
  }
}

class CategoryProductsScreen extends StatelessWidget {
  final String categoryId;

  const CategoryProductsScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Category: $categoryId')));
  }
}

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Product: $productId')));
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Cart')));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Profile')));
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

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Checkout')));
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Order Confirmation')));
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Orders')));
  }
}

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Order: $orderId')));
  }
}

class SearchScreen extends StatelessWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Search: $query')));
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
            RouteNames.catalog,
            RouteNames.cart,
            RouteNames.orders,
            RouteNames.profile,
          ];
          context.go(routes[index]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag),
            label: 'Catalog',
          ),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
