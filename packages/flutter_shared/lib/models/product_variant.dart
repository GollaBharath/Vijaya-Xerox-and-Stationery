/// Product variant model (e.g., color, B&W, size variations)
class ProductVariant {
  final String id;
  final String productId;
  final String variantType;
  final double price;
  final bool stock;
  final String sku;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.variantType,
    required this.price,
    required this.stock,
    required this.sku,
  });

  /// Check if variant is in stock
  bool get isInStock => stock;

  /// Convert ProductVariant to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'variant_type': variantType,
      'price': price,
      'stock': stock,
      'sku': sku,
    };
  }

  /// Create ProductVariant from JSON
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: (json['id'] ?? '') as String,
      // Support both snake_case and camelCase for API compatibility
      productId: (json['productId'] ?? json['product_id'] ?? '') as String,
      variantType:
          (json['variantType'] ?? json['variant_type'] ?? '') as String,
      price: ((json['price'] as num?) ?? 0).toDouble(),
      stock: (json['stock'] as bool?) ?? true,
      sku: (json['sku'] ?? '') as String,
    );
  }

  /// Create a copy of ProductVariant with optional field overrides
  ProductVariant copyWith({
    String? id,
    String? productId,
    String? variantType,
    double? price,
    bool? stock,
    String? sku,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantType: variantType ?? this.variantType,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
    );
  }

  @override
  String toString() {
    return 'ProductVariant(id: $id, type: $variantType, price: $price, stock: $stock)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductVariant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productId == other.productId;

  @override
  int get hashCode => id.hashCode ^ productId.hashCode;
}
