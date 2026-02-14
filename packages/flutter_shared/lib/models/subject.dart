/// Subject model for books and educational materials
class Subject {
  final String id;
  final String name;
  final String categoryId;
  final String? parentSubjectId;

  Subject({
    required this.id,
    required this.name,
    required this.categoryId,
    this.parentSubjectId,
  });

  /// Check if this subject has a parent (is a sub-subject)
  bool get hasParent => parentSubjectId != null;

  /// Convert Subject to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'parentSubjectId': parentSubjectId,
    };
  }

  /// Create Subject from JSON
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String,
      parentSubjectId: json['parentSubjectId'] as String?,
    );
  }

  /// Create a copy of Subject with optional field overrides
  Subject copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? parentSubjectId,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      parentSubjectId: parentSubjectId ?? this.parentSubjectId,
    );
  }

  @override
  String toString() {
    return 'Subject(id: $id, name: $name, categoryId: $categoryId, parentSubjectId: $parentSubjectId)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          categoryId == other.categoryId &&
          parentSubjectId == other.parentSubjectId;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ categoryId.hashCode ^ parentSubjectId.hashCode;
}
