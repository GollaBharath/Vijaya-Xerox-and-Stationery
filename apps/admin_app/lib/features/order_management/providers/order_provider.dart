import 'package:flutter/material.dart';
import 'package:flutter_shared/api/api_client.dart';
import 'package:flutter_shared/api/endpoints.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import 'package:flutter_shared/models/order.dart';
import '../../../core/config/env.dart';

/// Provider for managing orders in the admin panel
/// Handles fetching, viewing, updating status, and canceling orders
class OrderProvider extends ChangeNotifier {
  final TokenManager _tokenManager = TokenManager();
  late final ApiClient _apiClient;

  // State properties
  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  String _statusFilter =
      'ALL'; // ALL, PENDING, CONFIRMED, PROCESSING, DISPATCHED, DELIVERED, CANCELLED
  DateTime? _dateFilter;

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;
  String get statusFilter => _statusFilter;
  DateTime? get dateFilter => _dateFilter;

  OrderProvider() {
    _apiClient = ApiClient(baseUrl: Env.baseUrl, tokenManager: _tokenManager);
  }

  /// Fetch all orders with pagination and filters
  /// [page] - Page number (1-based)
  /// [limit] - Items per page (default 10)
  /// [statusFilter] - Filter by order status
  /// [dateFilter] - Filter by order date
  Future<void> fetchAllOrders({
    int page = 1,
    int limit = 10,
    String? statusFilter,
    DateTime? dateFilter,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _currentPage = page;
      _statusFilter = statusFilter ?? 'ALL';
      _dateFilter = dateFilter;
      notifyListeners();

      // Build query string manually since ApiClient.get() doesn't support queryParams
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (statusFilter != null && statusFilter != 'ALL')
          'status': statusFilter,
        if (dateFilter != null) 'date': dateFilter.toIso8601String(),
      };

      final queryString = params.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      final url = '${Endpoints.adminOrders}?$queryString';

      final response = await _apiClient.get(url);

      if (response['success'] == true) {
        final ordersData = (response['data'] as List?) ?? [];
        final pagination =
            response['pagination'] as Map<String, dynamic>? ?? {};
        _totalPages = pagination['totalPages'] as int? ?? 1;
        _hasMore = page < _totalPages;

        if (page == 1) {
          _orders = ordersData
              .map((o) => Order.fromJson(o as Map<String, dynamic>))
              .toList();
        } else {
          _orders.addAll(
            ordersData
                .map((o) => Order.fromJson(o as Map<String, dynamic>))
                .toList(),
          );
        }

        _isLoading = false;
        notifyListeners();
      } else {
        throw response['message'] ?? 'Failed to fetch orders';
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching orders: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Fetch details for a specific order
  /// [orderId] - ID of the order to fetch
  Future<void> fetchOrderDetails(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiClient.get(Endpoints.adminOrder(orderId));

      if (response['success'] == true) {
        _selectedOrder = Order.fromJson(response['data']);
        _isLoading = false;
        notifyListeners();
      } else {
        throw response['message'] ?? 'Failed to fetch order details';
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error fetching order details: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Update order status
  /// [orderId] - ID of the order
  /// [status] - New status (PENDING, CONFIRMED, PROCESSING, DISPATCHED, DELIVERED, CANCELLED)
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiClient.patch(
        Endpoints.adminOrder(orderId),
        body: {'status': status},
      );

      if (response['success'] == true) {
        // Update local order if it's the selected one
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = Order.fromJson(response['data']);
        }

        // Update in list
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = Order.fromJson(response['data']);
        }

        _isLoading = false;
        notifyListeners();
      } else {
        throw response['message'] ?? 'Failed to update order status';
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error updating order status: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Cancel an order
  /// [orderId] - ID of the order to cancel
  Future<void> cancelOrder(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiClient.post(
        Endpoints.adminOrderCancel(orderId),
        body: {},
      );

      if (response['success'] == true) {
        // Update local order if it's the selected one
        if (_selectedOrder?.id == orderId) {
          _selectedOrder = Order.fromJson(response['data']);
        }

        // Update in list
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = Order.fromJson(response['data']);
        }

        _isLoading = false;
        notifyListeners();
      } else {
        throw response['message'] ?? 'Failed to cancel order';
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Error canceling order: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Load more orders (pagination)
  Future<void> loadMoreOrders() async {
    if (!_hasMore || _isLoading) return;
    await fetchAllOrders(
      page: _currentPage + 1,
      statusFilter: _statusFilter != 'ALL' ? _statusFilter : null,
      dateFilter: _dateFilter,
    );
  }

  /// Clear filters and reset to initial state
  Future<void> clearFilters() async {
    _statusFilter = 'ALL';
    _dateFilter = null;
    await fetchAllOrders(page: 1);
  }

  /// Select an order from the list (without fetching details)
  void selectOrder(Order order) {
    _selectedOrder = order;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
