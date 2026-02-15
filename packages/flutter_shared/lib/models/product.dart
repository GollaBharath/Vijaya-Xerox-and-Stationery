import 'product_variant.dart';

/// Product model for stationery and books
class Product {
  final String id;
  final String title;
  final String description;
  final String? isbn;
  final double basePrice;
  final String subjectId;
  final String? imageUrl; // For stationery products
  final String? pdfUrl; // For book products
  final String? previewUrl; // Preview image for book products
  final String fileType; // 'IMAGE', 'PDF', or 'NONE'
  final bool isActive;
  final DateTime createdAt;
  final List<ProductVariant>? variants;
  final int likeCount;
  final bool isLikedByUser;

  Product({
    required this.id,
    required this.title,
    required this.description,
    this.isbn,
    required this.basePrice,
    required this.subjectId,
    this.imageUrl,
    this.pdfUrl,
    this.previewUrl,
    required this.fileType,
    required this.isActive,
    required this.createdAt,
    this.variants,
    this.likeCount = 0,
    this.isLikedByUser = false,
  });

  /// Check if product is a stationery (has image)
  bool get isStationery => fileType == 'IMAGE';

  /// Check if product is a book (has PDF)
  bool get isBook => fileType == 'PDF';

  /// Check if product has files
  bool get hasFiles => fileType != 'NONE';

  /// Get first variant price if available, else base price
  double get displayPrice {
    if (variants != null && variants!.isNotEmpty) {
      return variants!.first.price;
    }
    return basePrice;
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isbn': isbn,
      'base_price': basePrice,
      'subject_id': subjectId,
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
      'preview_url': previewUrl,
      'file_type': fileType,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'variants': variants?.map((v) => v.toJson()).toList(),
      'likeCount': likeCount,
      'isLikedByUser': isLikedByUser,
    };
  }

  /// Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      isbn: json['isbn'] as String?,
      basePrice:
          ((json['basePrice'] ?? json['base_price'] as num?) ?? 0).toDouble(),
      subjectId: (json['subjectId'] ?? json['subject_id'] as String?) ?? '',
      imageUrl: (json['imageUrl'] ?? json['image_url']) as String?,
      pdfUrl: (json['pdfUrl'] ?? json['pdf_url']) as String?,
      previewUrl: (json['previewUrl'] ?? json['preview_url']) as String?,
      fileType: (json['fileType'] ?? json['file_type'] as String?) ?? 'NONE',
      isActive: (json['isActive'] ?? json['is_active'] as bool?) ?? true,
      createdAt: DateTime.parse(
          (json['createdAt'] ?? json['created_at'] as String?) ??
              DateTime.now().toIso8601String()),
      variants: json['variants'] != null
          ? (json['variants'] as List)
              .map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
              .toList()
          : null,
      likeCount: (json['likeCount'] as int?) ?? 0,
      isLikedByUser: (json['isLikedByUser'] as bool?) ?? false,
    );
  }

  /// Create a copy of Product with optional field overrides
  Product copyWith({
    String? id,
    String? title,
    String? description,
    String? isbn,
    double? basePrice,
    String? subjectId,
    String? imageUrl,
    String? pdfUrl,
    String? previewUrl,
    String? fileType,
    bool? isActive,
    DateTime? createdAt,
    List<ProductVariant>? variants,
    int? likeCount,
    bool? isLikedByUser,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isbn: isbn ?? this.isbn,
      basePrice: basePrice ?? this.basePrice,
      subjectId: subjectId ?? this.subjectId,
      imageUrl: imageUrl ?? this.imageUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      fileType: fileType ?? this.fileType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      variants: variants ?? this.variants,
      likeCount: likeCount ?? this.likeCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, title: $title, fileType: $fileType, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
