import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';

/// Provider for managing products
class ProductProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  // State
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  static const int _pageSize = 20;

  // Filters
  String? _currentCategoryId;
  String? _currentSubjectId;

  ProductProvider(this._apiClient);

  // Getters
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasProducts => _products.isNotEmpty;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  /// Fetch products with filters and pagination
  Future<void> fetchProducts({
    String? categoryId,
    String? subjectId,
    bool reset = false,
  }) async {
    if (reset) {
      _products = [];
      _currentPage = 1;
      _hasMore = true;
      _currentCategoryId = categoryId;
      _currentSubjectId = subjectId;
    }

    if (!_hasMore && !reset) return;

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      // Build query params
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
      };

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }
      if (subjectId != null) {
        queryParams['subjectId'] = subjectId;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = '${ApiEndpoints.products}?$queryString';
      final response = await _apiClient.get(endpoint);

      if (response is Map<String, dynamic> &&
          response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;

        if (data['products'] is List) {
          final newProducts = (data['products'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();

          if (reset) {
            _products = newProducts;
          } else {
            _products.addAll(newProducts);
          }
          


          // Handle pagination metadata
          if (data['pagination'] is Map<String, dynamic>) {
            final pagination = data['pagination'] as Map<String, dynamic>;
            _currentPage = (pagination['currentPage'] as int?) ?? _currentPage;
            _totalPages = (pagination['totalPages'] as int?) ?? 1;
            _hasMore = _currentPage < _totalPages;
          } else {
            _hasMore = newProducts.length >= _pageSize;
          }

          if (_hasMore) {
            _currentPage++;
          }
        }
      } else if (response is List) {
        // Fallback if API returns list directly (without pagination)
        final newProducts = response
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();

        if (reset) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        _hasMore = false; // No more pages
      }

      _error = null;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('ProductProvider: Error fetching products - $e');
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more products (pagination)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    await fetchProducts(
      categoryId: _currentCategoryId,
      subjectId: _currentSubjectId,
      reset: false,
    );
  }

  /// Fetch single product details by ID
  Future<void> fetchProductDetails(String productId) async {
    _isLoading = true;
    _error = null;
    _selectedProduct = null;
    notifyListeners();

    try {
      final endpoint = ApiEndpoints.product(productId);
      final response = await _apiClient.get(endpoint);

      if (response is Map<String, dynamic>) {
        if (response['data'] is Map<String, dynamic>) {
          final data = response['data'] as Map<String, dynamic>;
          if (data['product'] is Map<String, dynamic>) {
            _selectedProduct = Product.fromJson(
              data['product'] as Map<String, dynamic>,
            );
          }
        } else if (response['id'] != null) {
          // Direct product response
          _selectedProduct = Product.fromJson(response);
        }
      }

      _error = null;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('ProductProvider: Error fetching product details - $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search products by query
  Future<void> searchProducts(String query, {bool reset = true}) async {
    if (reset) {
      _products = [];
      _currentPage = 1;
      _hasMore = true;
    }

    if (query.trim().isEmpty) {
      _products = [];
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'search': query,
        'page': _currentPage.toString(),
        'limit': _pageSize.toString(),
      };

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final endpoint = '${ApiEndpoints.products}?$queryString';
      final response = await _apiClient.get(endpoint);

      if (response is Map<String, dynamic> &&
          response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;

        if (data['products'] is List) {
          final newProducts = (data['products'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();

          if (reset) {
            _products = newProducts;
          } else {
            _products.addAll(newProducts);
          }

          // Handle pagination
          if (data['pagination'] is Map<String, dynamic>) {
            final pagination = data['pagination'] as Map<String, dynamic>;
            _currentPage = (pagination['currentPage'] as int?) ?? _currentPage;
            _totalPages = (pagination['totalPages'] as int?) ?? 1;
            _hasMore = _currentPage < _totalPages;
          } else {
            _hasMore = newProducts.length >= _pageSize;
          }

          if (_hasMore) {
            _currentPage++;
          }
        }
      }

      _error = null;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('ProductProvider: Error searching products - $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get active products only
  List<Product> get activeProducts {
    return _products.where((prod) => prod.isActive).toList();
  }

  /// Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  /// Reset filters and pagination
  void reset() {
    _products = [];
    _selectedProduct = null;
    _currentPage = 1;
    _totalPages = 1;
    _hasMore = true;
    _currentCategoryId = null;
    _currentSubjectId = null;
    _error = null;
    notifyListeners();
  }

  /// Format error message
  String _formatError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to load products. Please try again.';
  }
}
