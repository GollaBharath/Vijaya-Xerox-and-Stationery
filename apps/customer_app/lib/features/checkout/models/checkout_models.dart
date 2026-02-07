import 'package:flutter_shared/models/order.dart';

/// Checkout request model
class CheckoutRequest {
  final DeliveryAddress deliveryAddress;
  final String? paymentMethod; // 'RAZORPAY' or 'COD'

  CheckoutRequest({required this.deliveryAddress, this.paymentMethod});

  Map<String, dynamic> toJson() {
    return {
      'delivery_address': deliveryAddress.toJson(),
      if (paymentMethod != null) 'payment_method': paymentMethod,
    };
  }
}

/// Checkout response model
class CheckoutResponse {
  final Order order;
  final String? razorpayOrderId;
  final String? razorpayKeyId;

  CheckoutResponse({
    required this.order,
    this.razorpayOrderId,
    this.razorpayKeyId,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
      razorpayOrderId: json['razorpay_order_id'] as String?,
      razorpayKeyId: json['razorpay_key_id'] as String?,
    );
  }
}
