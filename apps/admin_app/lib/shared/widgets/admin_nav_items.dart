import 'package:flutter/material.dart';
import '../../routing/route_names.dart';

class AdminNavItem {
  final String label;
  final IconData icon;
  final String route;

  const AdminNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

const List<AdminNavItem> adminNavItems = [
  AdminNavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    route: RouteNames.dashboard,
  ),
  AdminNavItem(
    label: 'Categories',
    icon: Icons.category_outlined,
    route: RouteNames.categories,
  ),
  AdminNavItem(
    label: 'Subjects',
    icon: Icons.menu_book_outlined,
    route: RouteNames.subjects,
  ),
  AdminNavItem(
    label: 'Products',
    icon: Icons.inventory_2_outlined,
    route: RouteNames.products,
  ),
  AdminNavItem(
    label: 'Orders',
    icon: Icons.shopping_bag_outlined,
    route: RouteNames.orders,
  ),
  AdminNavItem(
    label: 'Users',
    icon: Icons.people_alt_outlined,
    route: RouteNames.users,
  ),
  AdminNavItem(
    label: 'Feedback',
    icon: Icons.star_outline,
    route: RouteNames.feedback,
  ),
  AdminNavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    route: RouteNames.settings,
  ),
];
