import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routing/app_router.dart';
import '../../routing/route_names.dart';
import '../../features/auth/providers/auth_provider.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text(
                'Admin Panel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            _buildNavItem(
              context,
              label: 'Dashboard',
              icon: Icons.dashboard,
              route: RouteNames.dashboard,
            ),
            _buildNavItem(
              context,
              label: 'Categories',
              icon: Icons.category,
              route: RouteNames.categories,
            ),
            _buildNavItem(
              context,
              label: 'Subjects',
              icon: Icons.menu_book,
              route: RouteNames.subjects,
            ),
            _buildNavItem(
              context,
              label: 'Products',
              icon: Icons.inventory,
              route: RouteNames.products,
            ),
            _buildNavItem(
              context,
              label: 'Orders',
              icon: Icons.shopping_bag,
              route: RouteNames.orders,
            ),
            _buildNavItem(
              context,
              label: 'Users',
              icon: Icons.people,
              route: RouteNames.users,
            ),
            _buildNavItem(
              context,
              label: 'Settings',
              icon: Icons.settings,
              route: RouteNames.settings,
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    AppRouter.pushAndRemoveUntil(context, RouteNames.login);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required String route,
  }) {
    final isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        if (isSelected) return;
        AppRouter.pushAndRemoveUntil(context, route);
      },
    );
  }
}
