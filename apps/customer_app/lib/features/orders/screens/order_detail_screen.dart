import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_shared/models/order.dart';
import '../providers/orders_provider.dart';
import '../../../core/config/env.dart';
import '../../../routing/route_names.dart';
import '../../feedback/widgets/feedback_dialog.dart';

/// Screen displaying detailed information about a specific order
class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    ordersProvider.fetchOrderDetails(widget.orderId);
  }

  Future<void> _onCancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel Order'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ordersProvider = Provider.of<OrdersProvider>(
        context,
        listen: false,
      );
      final success = await ordersProvider.cancelOrder(widget.orderId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (ordersProvider.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ordersProvider.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

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
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.orders),
        ),
        title: const Text('Order Details'),
      ),
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          if (ordersProvider.isLoading && ordersProvider.currentOrder == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ordersProvider.error != null &&
              ordersProvider.currentOrder == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    ordersProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOrderDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = ordersProvider.currentOrder;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }

          final canCancel = OrdersProvider.canCancelOrder(order.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order Info Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  order.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getStatusColor(order.status),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                OrdersProvider.getOrderStatusLabel(
                                  order.status,
                                ),
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Order ID',
                          '#${order.id.substring(0, 8).toUpperCase()}',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Order Date',
                          _formatDate(order.createdAt),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Payment Status',
                          order.paymentStatus,
                          valueColor:
                              order.paymentStatus.toUpperCase() == 'PAID'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Payment Method', order.paymentMethod),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Items Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        ...order.items.map(
                          (item) => _OrderItemCard(item: item),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Delivery Address Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Address',
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
                              Icons.location_on,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.deliveryAddress.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(order.deliveryAddress.phone),
                                  const SizedBox(height: 8),
                                  Text(order.deliveryAddress.line1),
                                  if (order.deliveryAddress.line2 != null &&
                                      order.deliveryAddress.line2!.isNotEmpty)
                                    Text(order.deliveryAddress.line2!),
                                  Text(
                                    '${order.deliveryAddress.city}, ${order.deliveryAddress.state}',
                                  ),
                                  Text('PIN: ${order.deliveryAddress.pincode}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Order Summary Card
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
                        _buildSummaryRow(
                          'Subtotal',
                          _formatCurrency(order.subtotal),
                        ),
                        const SizedBox(height: 8),
                        if (order.discountAmount > 0) ...[
                          _buildSummaryRow(
                            'Discount',
                            '-${_formatCurrency(order.discountAmount)}',
                            valueColor: Colors.green,
                          ),
                          const SizedBox(height: 8),
                        ],
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
                        if (order.tax > 0) ...[
                          _buildSummaryRow('Tax', _formatCurrency(order.tax)),
                          const SizedBox(height: 8),
                        ],
                        const Divider(height: 24),
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

                // Feedback Section (for delivered orders)
                if (order.status.toUpperCase() == 'DELIVERED')
                  _buildFeedbackSection(order),
                const SizedBox(height: 8),

                // Cancel Order Button
                if (canCancel)
                  OutlinedButton.icon(
                    onPressed: ordersProvider.isLoading ? null : _onCancelOrder,
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel Order'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor,
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

  Widget _buildFeedbackSection(Order order) {
    if (order.hasFeedback) {
      // Show existing feedback
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Feedback',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < order.feedback!.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${order.feedback!.rating}/5',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (order.feedback!.comment != null &&
                  order.feedback!.comment!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  order.feedback!.comment!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Submitted on ${DateFormat('MMM dd, yyyy').format(order.feedback!.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    } else {
      // Show button to submit feedback
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.feedback_outlined, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'How was your order?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Share your experience with us',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showFeedbackDialog(order.id),
                icon: const Icon(Icons.rate_review),
                label: const Text('Give Feedback'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _showFeedbackDialog(String orderId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => FeedbackDialog(orderId: orderId),
    );

    if (result == true) {
      // Refresh order details to show submitted feedback
      _loadOrderDetails();
    }
  }
}

/// Order item card widget
class _OrderItemCard extends StatelessWidget {
  final OrderItem item;

  const _OrderItemCard({required this.item});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  String _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    if (imagePath.startsWith('/')) {
      return '${Environment.apiBaseUrl}$imagePath';
    }
    return '${Environment.apiBaseUrl}/api/v1/files/images/products/$imagePath';
  }

  bool _hasImage() {
    return item.product?.imageUrl != null && item.product!.imageUrl!.isNotEmpty;
  }

  bool _hasPdf() {
    return item.product?.pdfUrl != null && item.product!.pdfUrl!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image or PDF Badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _hasImage()
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _getImageUrl(item.product!.imageUrl),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                : Center(
                    child: Icon(
                      _hasPdf() ? Icons.picture_as_pdf : Icons.inventory_2,
                      size: 32,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.title ?? 'Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.variant != null) ...[
                  Text(
                    'Variant: ${item.variant!.variantType}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(item.priceSnapshot * item.quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
