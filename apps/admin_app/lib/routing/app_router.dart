import 'package:flutter/material.dart';
import 'route_names.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/category_management/screens/categories_list_screen.dart';
import '../features/category_management/screens/category_form_screen.dart';
import '../features/subject_management/screens/subjects_list_screen.dart';
import '../features/subject_management/screens/subject_form_screen.dart';

/// Simple app router using Navigator 1.0
/// Routes will be properly configured as features are built
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case RouteNames.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );

      case RouteNames.categories:
        return MaterialPageRoute(
          builder: (_) => const CategoriesListScreen(),
          settings: settings,
        );

      case RouteNames.categoryForm:
        final categoryId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CategoryFormScreen(categoryId: categoryId),
          settings: settings,
        );

      case RouteNames.subjects:
        return MaterialPageRoute(
          builder: (_) => const SubjectsListScreen(),
          settings: settings,
        );

      case RouteNames.subjectForm:
        final subjectId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => SubjectFormScreen(subjectId: subjectId),
          settings: settings,
        );

      case RouteNames.products:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Products - To be implemented')),
          ),
          settings: settings,
        );

      case RouteNames.orders:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Orders - To be implemented')),
          ),
          settings: settings,
        );

      case RouteNames.users:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Users - To be implemented')),
          ),
          settings: settings,
        );

      case RouteNames.settings:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Settings - To be implemented')),
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route ${settings.name} not found')),
          ),
        );
    }
  }

  /// Navigate to a route by name
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigate to a route by name and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Replace the current route with a new one
  static Future<T?> pushReplacement<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, Object?>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Pop the current route
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Pop until reaching a specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }
}
