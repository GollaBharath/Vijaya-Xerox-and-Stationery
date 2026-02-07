import 'package:flutter/material.dart';
import 'package:flutter_shared/utils/formatters.dart';
import '../../../core/theme/colors.dart';
import '../../../core/config/constants.dart';
import '../providers/dashboard_provider.dart';

/// Recent orders list widget for dashboard
class RecentOrdersList extends StatelessWidget {
  final List<RecentOrder> orders;

  const RecentOrdersList({super.key, required this.orders});

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppColors.orderPending;
      case 'CONFIRMED':
        return AppColors.orderConfirmed;
      case 'SHIPPED':
        return AppColors.orderShipped;
      case 'DELIVERED':
        return AppColors.orderDelivered;
      case 'CANCELLED':
        return AppColors.orderCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 48, color: AppColors.textHint),
                const SizedBox(height: AppConstants.defaultPadding),
                Text(
                  'No recent orders',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(order.status).withAlpha(51),
              child: Icon(
                Icons.receipt,
                color: _getStatusColor(order.status),
                size: 20,
              ),
            ),
            title: Text(order.userName),
            subtitle: Text(
              Formatters.formatRelativeTime(order.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.formatPrice(order.totalPrice),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    Formatters.formatOrderStatus(order.status),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
