/// Category model for stationery products
class Category {
  final String id;
  final String name;
  final String? parentId;
  final Map<String, dynamic>? metadata;
  final bool isActive;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.parentId,
    this.metadata,
    required this.isActive,
    required this.createdAt,
  });

  /// Check if this category has a parent (is a subcategory)
  bool get hasParent => parentId != null;

  /// Convert Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'metadata': metadata,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Create a copy of Category with optional field overrides
  Category copyWith({
    String? id,
    String? name,
    String? parentId,
    Map<String, dynamic>? metadata,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, parentId: $parentId, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          parentId == other.parentId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ parentId.hashCode;
}
