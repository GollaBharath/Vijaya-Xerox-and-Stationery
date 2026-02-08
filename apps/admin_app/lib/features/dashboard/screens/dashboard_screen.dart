import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/utils/formatters.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../../../routing/app_router.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_orders_list.dart';
import '../widgets/navigation_card.dart';

/// Admin dashboard screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard stats on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardStats();
    });
  }

  Future<void> _handleRefresh() async {
    await context.read<DashboardProvider>().fetchDashboardStats();
  }

  Future<void> _handleLogout() async {
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

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        AppRouter.pushAndRemoveUntil(context, RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AdminScaffold(
      title: 'Dashboard',
      currentRoute: RouteNames.dashboard,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _handleRefresh,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _handleLogout,
          tooltip: 'Logout',
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, _) {
            // Loading state
            if (dashboardProvider.isLoading &&
                dashboardProvider.stats == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (dashboardProvider.errorMessage != null &&
                dashboardProvider.stats == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      Text(
                        dashboardProvider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      ElevatedButton(
                        onPressed: _handleRefresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final stats = dashboardProvider.stats;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Welcome, ${authProvider.currentUser?.name ?? 'Admin'}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Statistics cards
                  if (stats != null) ...[
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final cards = [
                          StatCard(
                            title: 'Total Users',
                            value: stats.totalUsers.toString(),
                            icon: Icons.people_outline,
                            color: const Color(0xFF4CAF50),
                          ),
                          StatCard(
                            title: 'Total Orders',
                            value: stats.totalOrders.toString(),
                            icon: Icons.shopping_cart_outlined,
                            color: const Color(0xFF2196F3),
                          ),
                          StatCard(
                            title: 'Total Revenue',
                            value: Formatters.formatPrice(stats.totalRevenue),
                            icon: Icons.account_balance_wallet_outlined,
                            color: const Color(0xFFFF9800),
                          ),
                          StatCard(
                            title: 'Recent Orders',
                            value: stats.recentOrders.length.toString(),
                            icon: Icons.receipt_long_outlined,
                            color: const Color(0xFF9C27B0),
                          ),
                        ];
                        return cards[index];
                      },
                    ),
                    const SizedBox(height: 32),

                    // Recent orders
                    Text(
                      'Recent Orders',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RecentOrdersList(orders: stats.recentOrders),
                    const SizedBox(height: 32),
                  ],

                  // Navigation cards
                  Text(
                    'Quick Actions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final cards = [
                        NavigationCard(
                          title: 'Categories',
                          icon: Icons.category_outlined,
                          color: const Color(0xFF3F51B5),
                          onTap: () =>
                              AppRouter.push(context, RouteNames.categories),
                        ),
                        NavigationCard(
                          title: 'Products',
                          icon: Icons.inventory_2_outlined,
                          color: const Color(0xFFE91E63),
                          onTap: () =>
                              AppRouter.push(context, RouteNames.products),
                        ),
                        NavigationCard(
                          title: 'Orders',
                          icon: Icons.shopping_bag_outlined,
                          color: const Color(0xFF00BCD4),
                          onTap: () =>
                              AppRouter.push(context, RouteNames.orders),
                        ),
                        NavigationCard(
                          title: 'Users',
                          icon: Icons.people_alt_outlined,
                          color: const Color(0xFFFF5722),
                          onTap: () =>
                              AppRouter.push(context, RouteNames.users),
                        ),
                      ];
                      return cards[index];
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
