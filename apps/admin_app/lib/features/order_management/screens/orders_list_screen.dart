import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';

/// Admin Orders List Screen
/// Displays all orders with filtering by status and date
/// Supports infinite scroll pagination
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({Key? key}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  late ScrollController _scrollController;
  String _selectedStatus = 'ALL';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchAllOrders();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<OrderProvider>().loadMoreOrders();
    }
  }

  void _handleStatusFilter(String status) {
    setState(() => _selectedStatus = status);
    context.read<OrderProvider>().fetchAllOrders(
      page: 1,
      statusFilter: status != 'ALL' ? status : null,
      dateFilter: _selectedDate,
    );
  }

  void _handleDateFilter() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      context.read<OrderProvider>().fetchAllOrders(
        page: 1,
        statusFilter: _selectedStatus != 'ALL' ? _selectedStatus : null,
        dateFilter: picked,
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = 'ALL';
      _selectedDate = null;
    });
    context.read<OrderProvider>().clearFilters();
  }

  String _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return '#FFA500'; // Orange
      case 'CONFIRMED':
        return '#4169E1'; // Royal Blue
      case 'PROCESSING':
        return '#FF6347'; // Tomato
      case 'DISPATCHED':
        return '#9370DB'; // Medium Purple
      case 'DELIVERED':
        return '#32CD32'; // Lime Green
      case 'CANCELLED':
        return '#DC143C'; // Crimson
      default:
        return '#808080'; // Gray
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.toString().split('.')[0]}';
  }

  String _formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Orders Management',
      currentRoute: RouteNames.orders,
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null && orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    orderProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => orderProvider.fetchAllOrders(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (orderProvider.orders.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No orders found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedStatus != 'ALL' || _selectedDate != null
                          ? 'Try adjusting your filters'
                          : 'Orders will appear here once customers place them',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => orderProvider.fetchAllOrders(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                        if (_selectedStatus != 'ALL' || _selectedDate != null)
                          ElevatedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.filter_alt_off),
                            label: const Text('Clear Filters'),
                          ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushReplacementNamed(
                            context,
                            RouteNames.dashboard,
                          ),
                          icon: const Icon(Icons.dashboard),
                          label: const Text('Go to Dashboard'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.fetchAllOrders(page: 1),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Filter chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter by Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected: _selectedStatus == 'ALL',
                                onSelected: (_) => _handleStatusFilter('ALL'),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Pending'),
                                selected: _selectedStatus == 'PENDING',
                                onSelected: (_) =>
                                    _handleStatusFilter('PENDING'),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Confirmed'),
                                selected: _selectedStatus == 'CONFIRMED',
                                onSelected: (_) =>
                                    _handleStatusFilter('CONFIRMED'),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Processing'),
                                selected: _selectedStatus == 'PROCESSING',
                                onSelected: (_) =>
                                    _handleStatusFilter('PROCESSING'),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Dispatched'),
                                selected: _selectedStatus == 'DISPATCHED',
                                onSelected: (_) =>
                                    _handleStatusFilter('DISPATCHED'),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Delivered'),
                                selected: _selectedStatus == 'DELIVERED',
                                onSelected: (_) =>
                                    _handleStatusFilter('DELIVERED'),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Cancelled'),
                                selected: _selectedStatus == 'CANCELLED',
                                onSelected: (_) =>
                                    _handleStatusFilter('CANCELLED'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _handleDateFilter,
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  _selectedDate == null
                                      ? 'Select Date'
                                      : 'Date: ${_selectedDate!.toString().split(' ')[0]}',
                                ),
                              ),
                            ),
                            if (_selectedDate != null ||
                                _selectedStatus != 'ALL')
                              const SizedBox(width: 8),
                            if (_selectedDate != null ||
                                _selectedStatus != 'ALL')
                              ElevatedButton.icon(
                                onPressed: _clearFilters,
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Orders list
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final order = orderProvider.orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailScreen(orderId: order.id),
                            ),
                          );
                        },
                        leading: Container(
                          width: 8,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(
                                _getStatusColor(
                                  order.status,
                                ).replaceFirst('#', '0xff'),
                              ),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(
                          'Order #${order.id.substring(0, 8).toUpperCase()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Items: ${order.items.length} | Total: ${_formatPrice(order.totalPrice)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(order.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(order.status),
                          backgroundColor: Color(
                            int.parse(
                              _getStatusColor(
                                order.status,
                              ).replaceFirst('#', '0xff'),
                            ),
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }, childCount: orderProvider.orders.length),
                ),

                // Loading indicator for pagination
                if (orderProvider.isLoading && orderProvider.orders.isNotEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // No more orders message
                if (!orderProvider.hasMore && orderProvider.orders.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No more orders',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
