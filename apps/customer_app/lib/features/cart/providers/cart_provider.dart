import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_shared/flutter_shared.dart';

/// Provider for managing shopping cart
class CartProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  // State
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  bool _isSynced = false;

  CartProvider(this._apiClient);

  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;
  int get itemCount => _cartItems.length;
  bool get isSynced => _isSynced;

  /// Get cart total price
  double get cartTotal {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item.quantity * _getItemPrice(item)),
    );
  }

  /// Get total number of items
  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Fetch cart from backend
  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(ApiEndpoints.cart);

      if (response is Map<String, dynamic> &&
          response['data'] is Map<String, dynamic>) {
        final data = response['data'] as Map<String, dynamic>;

        if (data['items'] is List) {
          _cartItems = (data['items'] as List)
              .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      } else if (response is List) {
        _cartItems = response
            .map((json) => CartItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      _isSynced = true;
      _error = null;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('CartProvider: Error fetching cart - $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add item to cart
  Future<bool> addToCart(String productVariantId, int quantity) async {
    _error = null;

    try {
      final requestBody = {
        'product_variant_id': productVariantId,
        'quantity': quantity,
      };

      final response = await _apiClient.post(
        ApiEndpoints.cart,
        body: requestBody,
      );

      if (response is Map<String, dynamic>) {
        // Fetch updated cart
        await fetchCart();
        return true;
      }

      return false;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('CartProvider: Error adding to cart - $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// Remove item from cart
  Future<bool> removeFromCart(String itemId) async {
    _error = null;

    try {
      final endpoint = ApiEndpoints.cartItem(itemId);
      await _apiClient.delete(endpoint);

      // Remove from local state
      _cartItems.removeWhere((item) => item.id == itemId);
      notifyListeners();

      return true;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('CartProvider: Error removing from cart - $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// Update item quantity
  Future<bool> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      return removeFromCart(itemId);
    }

    _error = null;

    try {
      final endpoint = ApiEndpoints.cartItem(itemId);
      final requestBody = {'quantity': quantity};

      await _apiClient.patch(endpoint, body: requestBody);

      // Update local state
      final index = _cartItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('CartProvider: Error updating quantity - $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// Increment item quantity
  Future<bool> incrementQuantity(String itemId) async {
    final item = _cartItems.firstWhere((item) => item.id == itemId);
    return updateQuantity(itemId, item.quantity + 1);
  }

  /// Decrement item quantity
  Future<bool> decrementQuantity(String itemId) async {
    final item = _cartItems.firstWhere((item) => item.id == itemId);
    if (item.quantity > 1) {
      return updateQuantity(itemId, item.quantity - 1);
    } else {
      return removeFromCart(itemId);
    }
  }

  /// Clear entire cart
  Future<bool> clearCart() async {
    _error = null;

    try {
      await _apiClient.post(ApiEndpoints.cartClear);

      _cartItems = [];
      notifyListeners();

      return true;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('CartProvider: Error clearing cart - $e');
      }
      notifyListeners();
      return false;
    }
  }

  /// Sync cart with backend (call after authentication)
  Future<void> syncCart() async {
    await fetchCart();
  }

  /// Clear local cart state (on logout)
  void clearLocalCart() {
    _cartItems = [];
    _isSynced = false;
    _error = null;
    notifyListeners();
  }

  /// Get item price (from variant)
  double _getItemPrice(CartItem item) {
    return item.variant?.price ?? 0.0;
  }

  /// Check if item exists in cart
  bool hasItem(String productVariantId) {
    return _cartItems.any((item) => item.productVariantId == productVariantId);
  }

  /// Get item quantity by variant ID
  int getItemQuantity(String productVariantId) {
    try {
      final item = _cartItems.firstWhere(
        (item) => item.productVariantId == productVariantId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  /// Format error message
  String _formatError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to update cart. Please try again.';
  }
}
