import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/checkout_provider.dart';
import '../../../routing/route_names.dart';

/// Screen showing order confirmation after successful checkout
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');
    return formatter.format(date);
  }

  DateTime _getEstimatedDeliveryDate() {
    // Estimate delivery in 5-7 business days
    final now = DateTime.now();
    return now.add(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<CheckoutProvider>(
        builder: (context, checkoutProvider, child) {
          final order = checkoutProvider.currentOrder;

          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('No order found', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.home),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Success icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Success message
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for your order',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Order details card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),

                        // Order ID
                        _buildDetailRow(
                          icon: Icons.receipt_long,
                          label: 'Order ID',
                          value: order.id,
                        ),
                        const SizedBox(height: 12),

                        // Order Date
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Order Date',
                          value: _formatDate(order.createdAt),
                        ),
                        const SizedBox(height: 12),

                        // Order Status
                        _buildDetailRow(
                          icon: Icons.info_outline,
                          label: 'Status',
                          value: order.status,
                          valueColor: _getStatusColor(order.status),
                        ),
                        const SizedBox(height: 12),

                        // Payment Status
                        _buildDetailRow(
                          icon: Icons.payment,
                          label: 'Payment',
                          value: order.paymentStatus,
                          valueColor: _getStatusColor(order.paymentStatus),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order items summary
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),

                        // Items count
                        _buildSummaryRow('Items', '${order.items.length}'),
                        const SizedBox(height: 8),

                        // Subtotal
                        _buildSummaryRow(
                          'Subtotal',
                          _formatCurrency(order.subtotal),
                        ),
                        const SizedBox(height: 8),

                        // Discount (if any)
                        if (order.discountAmount > 0) ...[
                          _buildSummaryRow(
                            'Discount',
                            '-${_formatCurrency(order.discountAmount)}',
                            valueColor: Colors.green,
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Shipping
                        _buildSummaryRow(
                          'Shipping',
                          order.shippingCost > 0
                              ? _formatCurrency(order.shippingCost)
                              : 'FREE',
                          valueColor: order.shippingCost == 0
                              ? Colors.green
                              : null,
                        ),
                        const SizedBox(height: 8),

                        // Tax (if any)
                        if (order.tax > 0) ...[
                          _buildSummaryRow('Tax', _formatCurrency(order.tax)),
                          const SizedBox(height: 8),
                        ],

                        const Divider(height: 24),

                        // Total
                        _buildSummaryRow(
                          'Total',
                          _formatCurrency(order.totalPrice),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Delivery information
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Estimated Delivery',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(_getEstimatedDeliveryDate()),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delivery Address',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatAddress(order.deliveryAddress),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Action buttons
                ElevatedButton(
                  onPressed: () {
                    context.go(RouteNames.orders);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Order Details',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () {
                    // Clear checkout state
                    checkoutProvider.clearCheckout();
                    context.go(RouteNames.home);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
      case 'PROCESSING':
        return Colors.blue;
      case 'DISPATCHED':
        return Colors.purple;
      case 'DELIVERED':
      case 'PAID':
        return Colors.green;
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatAddress(dynamic address) {
    if (address == null) return 'N/A';

    final parts = <String>[];

    if (address.name != null && address.name.isNotEmpty) {
      parts.add(address.name);
    }
    if (address.line1 != null && address.line1.isNotEmpty) {
      parts.add(address.line1);
    }
    if (address.line2 != null && address.line2.isNotEmpty) {
      parts.add(address.line2);
    }
    if (address.city != null && address.city.isNotEmpty) {
      parts.add(address.city);
    }
    if (address.state != null && address.state.isNotEmpty) {
      parts.add(address.state);
    }
    if (address.pincode != null && address.pincode.isNotEmpty) {
      parts.add(address.pincode);
    }

    return parts.join(', ');
  }
}
