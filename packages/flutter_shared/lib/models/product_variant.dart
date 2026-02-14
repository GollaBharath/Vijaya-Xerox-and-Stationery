/// Simple product info embedded in variant
class ProductInfo {
  final String id;
  final String title;
  final double basePrice;
  final bool isActive;
  final String? imageUrl;
  final String? fileType;

  ProductInfo({
    required this.id,
    required this.title,
    required this.basePrice,
    required this.isActive,
    this.imageUrl,
    this.fileType,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      basePrice:
          ((json['basePrice'] ?? json['base_price'] ?? 0) as num).toDouble(),
      isActive: (json['isActive'] ?? json['is_active'] ?? true) as bool,
      imageUrl: json['imageUrl'] ?? json['image_url'] as String?,
      fileType: json['fileType'] ?? json['file_type'] as String?,
    );
  }
}

/// Product variant model (e.g., color, B&W, size variations)
class ProductVariant {
  final String id;
  final String productId;
  final String variantType;
  final double price;
  final bool stock;
  final String sku;
  final ProductInfo? product;

  ProductVariant({
    required this.id,
    required this.productId,
    required this.variantType,
    required this.price,
    required this.stock,
    required this.sku,
    this.product,
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
      if (product != null)
        'product': {
          'id': product!.id,
          'title': product!.title,
          'base_price': product!.basePrice,
          'is_active': product!.isActive,
          'image_url': product!.imageUrl,
          'file_type': product!.fileType,
        },
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
      product: json['product'] != null
          ? ProductInfo.fromJson(json['product'] as Map<String, dynamic>)
          : null,
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
    ProductInfo? product,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantType: variantType ?? this.variantType,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      sku: sku ?? this.sku,
      product: product ?? this.product,
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
