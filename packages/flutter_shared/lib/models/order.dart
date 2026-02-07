import 'product.dart';
import 'product_variant.dart';

/// Order model representing a customer purchase
class OrderItem {
  final String id;
  final String orderId;
  final String productVariantId;
  final int quantity;
  final double priceSnapshot;
  final Product? product; // Full product info for display
  final ProductVariant? variant; // Full variant info for display

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productVariantId,
    required this.quantity,
    required this.priceSnapshot,
    this.product,
    this.variant,
  });

  /// Get total for this order item
  double getTotal() => priceSnapshot * quantity;

  /// Convert OrderItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_variant_id': productVariantId,
      'quantity': quantity,
      'price_snapshot': priceSnapshot,
      'product': product?.toJson(),
      'variant': variant?.toJson(),
    };
  }

  /// Create OrderItem from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productVariantId: json['product_variant_id'] as String,
      quantity: json['quantity'] as int,
      priceSnapshot: (json['price_snapshot'] as num).toDouble(),
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      variant: json['variant'] != null
          ? ProductVariant.fromJson(json['variant'] as Map<String, dynamic>)
          : null,
    );
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productVariantId,
    int? quantity,
    double? priceSnapshot,
    Product? product,
    ProductVariant? variant,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productVariantId: productVariantId ?? this.productVariantId,
      quantity: quantity ?? this.quantity,
      priceSnapshot: priceSnapshot ?? this.priceSnapshot,
      product: product ?? this.product,
      variant: variant ?? this.variant,
    );
  }
}

/// Delivery Address model
class DeliveryAddress {
  final String name;
  final String phone;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;

  DeliveryAddress({
    required this.name,
    required this.phone,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      name: json['name'] as String,
      phone: json['phone'] as String,
      line1: json['line1'] as String,
      line2: json['line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
    );
  }
}

/// Order model
class Order {
  final String id;
  final String userId;
  final String
      status; // 'PENDING', 'CONFIRMED', 'PROCESSING', 'DISPATCHED', 'DELIVERED', 'CANCELLED'
  final double totalPrice;
  final double subtotal;
  final double discountAmount;
  final double shippingCost;
  final double tax;
  final String paymentStatus; // 'PENDING', 'PAID', 'FAILED'
  final String paymentMethod; // 'RAZORPAY', 'COD', etc.
  final DeliveryAddress deliveryAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.subtotal,
    required this.discountAmount,
    required this.shippingCost,
    required this.tax,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.deliveryAddress,
    required this.createdAt,
    this.updatedAt,
    required this.items,
  });

  /// Check if order is delivered
  bool get isDelivered => status == 'DELIVERED';

  /// Check if order is cancelled
  bool get isCancelled => status == 'CANCELLED';

  /// Check if payment is completed
  bool get isPaid => paymentStatus == 'PAID';

  /// Convert Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'total_price': totalPrice,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'shipping_cost': shippingCost,
      'tax': tax,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'delivery_address': deliveryAddress.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  /// Create Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String,
      paymentMethod: json['payment_method'] as String? ?? 'RAZORPAY',
      deliveryAddress: json['delivery_address'] != null
          ? DeliveryAddress.fromJson(
              json['delivery_address'] as Map<String, dynamic>)
          : DeliveryAddress(
              name: 'N/A',
              phone: 'N/A',
              line1: 'N/A',
              city: 'N/A',
              state: 'N/A',
              pincode: 'N/A',
            ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  /// Create a copy of Order with optional field overrides
  Order copyWith({
    String? id,
    String? userId,
    String? status,
    double? totalPrice,
    double? subtotal,
    double? discountAmount,
    double? shippingCost,
    double? tax,
    String? paymentStatus,
    String? paymentMethod,
    DeliveryAddress? deliveryAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, status: $status, totalPrice: $totalPrice, paymentStatus: $paymentStatus)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
