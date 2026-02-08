import 'product_variant.dart';

/// Cart item model representing a product variant in user's cart
class CartItem {
  final String id;
  final String userId;
  final String productVariantId;
  final int quantity;
  final DateTime createdAt;
  final ProductVariant? variant; // Optional, can be populated from API

  CartItem({
    required this.id,
    required this.userId,
    required this.productVariantId,
    required this.quantity,
    required this.createdAt,
    this.variant,
  });

  /// Get total price for this cart item
  double getTotal() {
    if (variant != null) {
      return variant!.price * quantity;
    }
    return 0.0;
  }

  /// Convert CartItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_variant_id': productVariantId,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'variant': variant?.toJson(),
    };
  }

  /// Create CartItem from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      // Support both snake_case and camelCase for API compatibility
      userId: (json['userId'] ?? json['user_id']) as String,
      productVariantId:
          (json['productVariantId'] ?? json['product_variant_id']) as String,
      quantity: json['quantity'] as int,
      // Support both snake_case and camelCase for createdAt
      createdAt:
          DateTime.parse((json['createdAt'] ?? json['created_at']) as String),
      variant: json['variant'] != null
          ? ProductVariant.fromJson(json['variant'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Create a copy of CartItem with optional field overrides
  CartItem copyWith({
    String? id,
    String? userId,
    String? productVariantId,
    int? quantity,
    DateTime? createdAt,
    ProductVariant? variant,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productVariantId: productVariantId ?? this.productVariantId,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      variant: variant ?? this.variant,
    );
  }

  @override
  String toString() {
    return 'CartItem(id: $id, variantId: $productVariantId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
