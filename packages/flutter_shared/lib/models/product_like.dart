class ProductLike {
  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;

  ProductLike({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
  });

  factory ProductLike.fromJson(Map<String, dynamic> json) {
    return ProductLike(
      id: json['id'] as String,
      userId: json['userId'] as String,
      productId: json['productId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
