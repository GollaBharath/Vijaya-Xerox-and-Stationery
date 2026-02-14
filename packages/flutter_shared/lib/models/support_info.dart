// Support Info Model

class SupportInfo {
  final String id;
  final String? shopName;
  final String? shopPhone;
  final String? shopEmail;
  final String? shopWhatsapp;
  final String? shopAddress;
  final String? developerName;
  final String? developerEmail;
  final String? developerWhatsapp;
  final String? workingHours;
  final String? websiteUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportInfo({
    required this.id,
    this.shopName,
    this.shopPhone,
    this.shopEmail,
    this.shopWhatsapp,
    this.shopAddress,
    this.developerName,
    this.developerEmail,
    this.developerWhatsapp,
    this.workingHours,
    this.websiteUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportInfo.fromJson(Map<String, dynamic> json) {
    return SupportInfo(
      id: json['id'] as String,
      shopName: json['shopName'] as String?,
      shopPhone: json['shopPhone'] as String?,
      shopEmail: json['shopEmail'] as String?,
      shopWhatsapp: json['shopWhatsapp'] as String?,
      shopAddress: json['shopAddress'] as String?,
      developerName: json['developerName'] as String?,
      developerEmail: json['developerEmail'] as String?,
      developerWhatsapp: json['developerWhatsapp'] as String?,
      workingHours: json['workingHours'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopName': shopName,
      'shopPhone': shopPhone,
      'shopEmail': shopEmail,
      'shopWhatsapp': shopWhatsapp,
      'shopAddress': shopAddress,
      'developerName': developerName,
      'developerEmail': developerEmail,
      'developerWhatsapp': developerWhatsapp,
      'workingHours': workingHours,
      'websiteUrl': websiteUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
