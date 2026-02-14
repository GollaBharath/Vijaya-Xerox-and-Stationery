/// User Profile Model with address information
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? landmark;
  final String createdAt;
  final String updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.landmark,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      landmark: json['landmark'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasCompleteAddress {
    return address != null &&
        address!.isNotEmpty &&
        city != null &&
        city!.isNotEmpty &&
        state != null &&
        state!.isNotEmpty &&
        pincode != null &&
        pincode!.isNotEmpty;
  }
}
