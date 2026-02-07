/// Subject model for books and educational materials
class Subject {
  final String id;
  final String name;
  final String? parentSubjectId;

  Subject({required this.id, required this.name, this.parentSubjectId});

  /// Check if this subject has a parent (is a sub-subject)
  bool get hasParent => parentSubjectId != null;

  /// Convert Subject to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'parent_subject_id': parentSubjectId};
  }

  /// Create Subject from JSON
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      parentSubjectId: json['parent_subject_id'] as String?,
    );
  }

  /// Create a copy of Subject with optional field overrides
  Subject copyWith({String? id, String? name, String? parentSubjectId}) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      parentSubjectId: parentSubjectId ?? this.parentSubjectId,
    );
  }

  @override
  String toString() {
    return 'Subject(id: $id, name: $name, parentSubjectId: $parentSubjectId)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          parentSubjectId == other.parentSubjectId;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ parentSubjectId.hashCode;
}
