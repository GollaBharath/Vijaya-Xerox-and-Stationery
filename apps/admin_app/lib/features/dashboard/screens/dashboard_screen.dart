import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/utils/formatters.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/constants.dart';
import '../../../routing/route_names.dart';
import '../../../routing/app_router.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
      ),
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
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Welcome, ${authProvider.currentUser?.name ?? 'Admin'}!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Statistics cards
                  if (stats != null) ...[
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: AppConstants.defaultPadding,
                      mainAxisSpacing: AppConstants.defaultPadding,
                      childAspectRatio: 1.5,
                      children: [
                        StatCard(
                          title: 'Total Users',
                          value: stats.totalUsers.toString(),
                          icon: Icons.people,
                          color: AppColors.primary,
                        ),
                        StatCard(
                          title: 'Total Orders',
                          value: stats.totalOrders.toString(),
                          icon: Icons.shopping_cart,
                          color: AppColors.secondary,
                        ),
                        StatCard(
                          title: 'Total Revenue',
                          value: Formatters.formatPrice(stats.totalRevenue),
                          icon: Icons.attach_money,
                          color: AppColors.success,
                        ),
                        StatCard(
                          title: 'Recent Orders',
                          value: stats.recentOrders.length.toString(),
                          icon: Icons.receipt,
                          color: AppColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.largePadding),

                    // Recent orders
                    Text(
                      'Recent Orders',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),
                    RecentOrdersList(orders: stats.recentOrders),
                    const SizedBox(height: AppConstants.largePadding),
                  ],

                  // Navigation cards
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: AppConstants.defaultPadding,
                    mainAxisSpacing: AppConstants.defaultPadding,
                    childAspectRatio: 1.3,
                    children: [
                      NavigationCard(
                        title: 'Categories',
                        icon: Icons.category,
                        color: AppColors.primary,
                        onTap: () =>
                            AppRouter.push(context, RouteNames.categories),
                      ),
                      NavigationCard(
                        title: 'Products',
                        icon: Icons.inventory,
                        color: AppColors.secondary,
                        onTap: () =>
                            AppRouter.push(context, RouteNames.products),
                      ),
                      NavigationCard(
                        title: 'Orders',
                        icon: Icons.shopping_bag,
                        color: AppColors.success,
                        onTap: () => AppRouter.push(context, RouteNames.orders),
                      ),
                      NavigationCard(
                        title: 'Users',
                        icon: Icons.people,
                        color: AppColors.info,
                        onTap: () => AppRouter.push(context, RouteNames.users),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
