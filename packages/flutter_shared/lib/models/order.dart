/// Order model representing a customer purchase
class OrderItem {
  final String id;
  final String orderId;
  final String productVariantId;
  final int quantity;
  final double priceSnapshot;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productVariantId,
    required this.quantity,
    required this.priceSnapshot,
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
    );
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productVariantId,
    int? quantity,
    double? priceSnapshot,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productVariantId: productVariantId ?? this.productVariantId,
      quantity: quantity ?? this.quantity,
      priceSnapshot: priceSnapshot ?? this.priceSnapshot,
    );
  }
}

/// Order model
class Order {
  final String id;
  final String userId;
  final String
  status; // 'PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED'
  final double totalPrice;
  final String paymentStatus; // 'PENDING', 'PAID', 'FAILED'
  final Map<String, dynamic>?
  addressSnapshot; // Delivery address stored as JSON
  final DateTime createdAt;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalPrice,
    required this.paymentStatus,
    this.addressSnapshot,
    required this.createdAt,
    this.items,
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
      'payment_status': paymentStatus,
      'address_snapshot': addressSnapshot,
      'created_at': createdAt.toIso8601String(),
      'items': items?.map((i) => i.toJson()).toList(),
    };
  }

  /// Create Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      totalPrice: (json['total_price'] as num).toDouble(),
      paymentStatus: json['payment_status'] as String,
      addressSnapshot: json['address_snapshot'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: json['items'] != null
          ? (json['items'] as List)
                .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  /// Create a copy of Order with optional field overrides
  Order copyWith({
    String? id,
    String? userId,
    String? status,
    double? totalPrice,
    String? paymentStatus,
    Map<String, dynamic>? addressSnapshot,
    DateTime? createdAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      addressSnapshot: addressSnapshot ?? this.addressSnapshot,
      createdAt: createdAt ?? this.createdAt,
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
