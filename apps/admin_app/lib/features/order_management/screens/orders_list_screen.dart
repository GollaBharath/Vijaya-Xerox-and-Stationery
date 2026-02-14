import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../routing/route_names.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../providers/order_provider.dart';
import 'order_detail_screen.dart';

/// Admin Orders List Screen
/// Displays orders in two tabs: Ongoing and Completed
/// Supports infinite scroll pagination
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({Key? key}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  DateTime? _selectedDate;
  
  // Define order statuses for each tab
  static const List<String> _ongoingStatuses = [
    'PENDING',
    'CONFIRMED',
    'PROCESSING',
    'DISPATCHED',
  ];
  
  static const List<String> _completedStatuses = [
    'DELIVERED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load initial orders (ongoing by default)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOrdersForCurrentTab();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<OrderProvider>().loadMoreOrders();
    }
  }
  
  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _fetchOrdersForCurrentTab();
    }
  }
  
  void _fetchOrdersForCurrentTab() {
    final statuses = _tabController.index == 0 
        ? _ongoingStatuses 
        : _completedStatuses;
    
    // Fetch orders with multiple status filters
    // Since the backend doesn't support multiple statuses in one call,
    // we'll need to fetch all and filter client-side
    // For now, we'll fetch all orders and filter in the UI
    context.read<OrderProvider>().fetchAllOrders(
      page: 1,
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
      _fetchOrdersForCurrentTab();
    }
  }

  void _clearDateFilter() {
    setState(() => _selectedDate = null);
    _fetchOrdersForCurrentTab();
  }
  
  List<dynamic> _getFilteredOrders(List<dynamic> allOrders) {
    final statuses = _tabController.index == 0 
        ? _ongoingStatuses 
        : _completedStatuses;
    
    return allOrders.where((order) => statuses.contains(order.status)).toList();
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Orders Management',
      currentRoute: RouteNames.orders,
      body: Column(
        children: [
          // TabBar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(
                  icon: Icon(Icons.pending_actions),
                  text: 'Ongoing',
                ),
                Tab(
                  icon: Icon(Icons.check_circle_outline),
                  text: 'Completed',
                ),
              ],
            ),
          ),
          
          // Date Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleDateFilter,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _selectedDate == null
                          ? 'Filter by Date'
                          : 'Date: ${_selectedDate!.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                if (_selectedDate != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _clearDateFilter,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(isOngoing: true),
                _buildOrdersList(isOngoing: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrdersList({required bool isOngoing}) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        // Filter orders based on tab
        final filteredOrders = _getFilteredOrders(orderProvider.orders);
        
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
                  onPressed: () => _fetchOrdersForCurrentTab(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (filteredOrders.isEmpty) {
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
                  Text(
                    isOngoing ? 'No ongoing orders' : 'No completed orders',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedDate != null
                        ? 'Try adjusting your date filter'
                        : isOngoing 
                            ? 'Active orders will appear here'
                            : 'Delivered and cancelled orders will appear here',
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
                        onPressed: () => _fetchOrdersForCurrentTab(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                      if (_selectedDate != null)
                        ElevatedButton.icon(
                          onPressed: _clearDateFilter,
                          icon: const Icon(Icons.filter_alt_off),
                          label: const Text('Clear Filter'),
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
          onRefresh: () async => _fetchOrdersForCurrentTab(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length + 
                (orderProvider.isLoading ? 1 : 0) + 
                (!orderProvider.hasMore && filteredOrders.isNotEmpty ? 1 : 0),
            itemBuilder: (context, index) {
              // Loading indicator
              if (index == filteredOrders.length && orderProvider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              // No more orders message
              if (index == filteredOrders.length && !orderProvider.hasMore) {
                return Padding(
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
                );
              }
              
              final order = filteredOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(orderId: order.id),
                      ),
                    );
                  },
                  leading: Container(
                    width: 8,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                          _getStatusColor(order.status).replaceFirst('#', '0xff'),
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
                        _getStatusColor(order.status).replaceFirst('#', '0xff'),
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
            },
          ),
        );
      },
    );
  }
}
