/// User model representing a user in the Vijaya Xerox system
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'ADMIN' or 'CUSTOMER'
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  /// Check if user is admin
  bool get isAdmin => role == 'ADMIN';

  /// Check if user is customer
  bool get isCustomer => role == 'CUSTOMER';

  /// Convert User to JSON
  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Create a copy of User with optional field overrides
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, role: $role)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          role == other.role &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      role.hashCode ^
      isActive.hashCode;
}
