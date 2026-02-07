import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';

/// Provider for managing user orders
class OrdersProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  // State
  List<Order> _orders = [];
  Order? _currentOrder;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  OrdersProvider(this._apiClient);

  // Getters
  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _hasMore;
  bool get isEmpty => _orders.isEmpty;

  /// Fetch user orders with pagination
  Future<void> fetchUserOrders({
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _orders.clear();
      _hasMore = true;
    }

    if (_isLoading || (!refresh && !_hasMore)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = {'page': page.toString(), 'limit': limit.toString()};

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final endpoint = '${ApiEndpoints.orders}?$queryString';

      final response = await _apiClient.get(endpoint);

      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response;

        // Handle paginated response
        if (data is Map<String, dynamic>) {
          if (data['orders'] is List) {
            final newOrders = (data['orders'] as List)
                .map((json) => Order.fromJson(json as Map<String, dynamic>))
                .toList();

            if (refresh) {
              _orders = newOrders;
            } else {
              _orders.addAll(newOrders);
            }

            // Update pagination info
            _currentPage = data['currentPage'] ?? page;
            _totalPages = data['totalPages'] ?? 1;
            _hasMore = _currentPage < _totalPages;
          } else if (data['items'] is List) {
            // Alternative response structure
            final newOrders = (data['items'] as List)
                .map((json) => Order.fromJson(json as Map<String, dynamic>))
                .toList();

            if (refresh) {
              _orders = newOrders;
            } else {
              _orders.addAll(newOrders);
            }

            _currentPage = data['page'] ?? page;
            _totalPages = data['totalPages'] ?? 1;
            _hasMore = _currentPage < _totalPages;
          }
        } else if (data is List) {
          // Direct list response
          final newOrders = data
              .map((json) => Order.fromJson(json as Map<String, dynamic>))
              .toList();

          if (refresh) {
            _orders = newOrders;
          } else {
            _orders.addAll(newOrders);
          }

          _hasMore = newOrders.length >= limit;
        }
      } else if (response is List) {
        final newOrders = response
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
            .toList();

        if (refresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        _hasMore = newOrders.length >= limit;
      }

      _error = null;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('OrdersProvider: Error fetching orders - $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch order details by ID
  Future<bool> fetchOrderDetails(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.order(orderId));

      if (response is Map<String, dynamic>) {
        final data = response['data'] ?? response;
        _currentOrder = Order.fromJson(data);

        // Update order in the list if it exists
        final index = _orders.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          _orders[index] = _currentOrder!;
        }

        _error = null;
        notifyListeners();
        return true;
      }

      _error = 'Failed to load order details';
      notifyListeners();
      return false;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('OrdersProvider: Error fetching order details - $e');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more orders (pagination)
  Future<void> loadMore() async {
    if (_hasMore && !_isLoading) {
      await fetchUserOrders(page: _currentPage + 1);
    }
  }

  /// Refresh orders list
  Future<void> refresh() async {
    await fetchUserOrders(refresh: true);
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.order(orderId)}/cancel',
        body: {},
      );

      if (response is Map<String, dynamic>) {
        // Refresh order details
        await fetchOrderDetails(orderId);
        return true;
      }

      return false;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('OrdersProvider: Error cancelling order - $e');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current order
  void clearCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Format error message
  String _formatError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to load orders. Please try again.';
  }

  /// Get order status color
  static String getOrderStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PROCESSING':
        return 'Processing';
      case 'DISPATCHED':
        return 'Dispatched';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Check if order can be cancelled
  static bool canCancelOrder(String status) {
    final nonCancellableStatuses = ['DISPATCHED', 'DELIVERED', 'CANCELLED'];
    return !nonCancellableStatuses.contains(status.toUpperCase());
  }
}
