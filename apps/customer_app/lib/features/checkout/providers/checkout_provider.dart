import 'package:flutter/foundation.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../models/checkout_models.dart';

/// Provider for managing checkout process
class CheckoutProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  // State
  Order? _currentOrder;
  String? _razorpayOrderId;
  String? _razorpayKeyId;
  bool _isLoading = false;
  String? _error;
  DeliveryAddress? _deliveryAddress;

  CheckoutProvider(this._apiClient);

  // Getters
  Order? get currentOrder => _currentOrder;
  String? get razorpayOrderId => _razorpayOrderId;
  String? get razorpayKeyId => _razorpayKeyId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DeliveryAddress? get deliveryAddress => _deliveryAddress;

  /// Set delivery address for checkout
  void setDeliveryAddress(DeliveryAddress address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  /// Validate delivery address
  bool validateAddress(DeliveryAddress address) {
    if (address.name.trim().isEmpty) {
      _error = 'Name is required';
      notifyListeners();
      return false;
    }

    if (address.phone.trim().isEmpty) {
      _error = 'Phone number is required';
      notifyListeners();
      return false;
    }

    // Basic phone validation (10 digits)
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(address.phone.trim())) {
      _error = 'Phone number must be 10 digits';
      notifyListeners();
      return false;
    }

    if (address.line1.trim().isEmpty) {
      _error = 'Address line 1 is required';
      notifyListeners();
      return false;
    }

    if (address.city.trim().isEmpty) {
      _error = 'City is required';
      notifyListeners();
      return false;
    }

    if (address.state.trim().isEmpty) {
      _error = 'State is required';
      notifyListeners();
      return false;
    }

    if (address.pincode.trim().isEmpty) {
      _error = 'Pincode is required';
      notifyListeners();
      return false;
    }

    // Basic pincode validation (6 digits)
    final pincodeRegex = RegExp(r'^\d{6}$');
    if (!pincodeRegex.hasMatch(address.pincode.trim())) {
      _error = 'Pincode must be 6 digits';
      notifyListeners();
      return false;
    }

    _error = null;
    notifyListeners();
    return true;
  }

  /// Place order with delivery address
  Future<bool> placeOrder({
    required DeliveryAddress address,
    String? paymentMethod,
  }) async {
    if (!validateAddress(address)) {
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final checkoutRequest = CheckoutRequest(
        deliveryAddress: address,
        paymentMethod: paymentMethod,
      );

      final response = await _apiClient.post(
        ApiEndpoints.orders,
        body: checkoutRequest.toJson(),
      );

      if (response is Map<String, dynamic>) {
        // Handle wrapped response
        final data = response['data'] ?? response;
        final checkoutResponse = CheckoutResponse.fromJson(data);

        _currentOrder = checkoutResponse.order;
        _razorpayOrderId = checkoutResponse.razorpayOrderId;
        _razorpayKeyId = checkoutResponse.razorpayKeyId;
        _deliveryAddress = address;

        notifyListeners();
        return true;
      }

      _error = 'Invalid response from server';
      notifyListeners();
      return false;
    } catch (e) {
      _error = _formatError(e);
      if (kDebugMode) {
        print('CheckoutProvider: Error placing order - $e');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get payment link for Razorpay (if needed)
  String? getPaymentLink(String orderId) {
    if (_razorpayOrderId != null && _razorpayKeyId != null) {
      // In actual implementation, this would return a Razorpay payment link
      // or trigger Razorpay SDK to open payment UI
      return 'razorpay://pay?order_id=$_razorpayOrderId';
    }
    return null;
  }

  /// Clear checkout state
  void clearCheckout() {
    _currentOrder = null;
    _razorpayOrderId = null;
    _razorpayKeyId = null;
    _deliveryAddress = null;
    _error = null;
    notifyListeners();
  }

  /// Reset error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Format error message
  String _formatError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Failed to place order. Please try again.';
  }
}
