class OrderFeedback {
  final String id;
  final String orderId;
  final String userId;
  final String userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderFeedback({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderFeedback.fromJson(Map<String, dynamic> json) {
    return OrderFeedback(
      id: json['id'],
      orderId: json['orderId'],
      userId: json['userId'],
      userName: json['userName'] ?? 'Unknown',
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
