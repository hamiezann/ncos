class Rating {
  final int id;
  final int userId;
  final int rating;
  final String? description;
  final int orderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.userId,
    required this.rating,
    this.description,
    required this.orderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      userId: json['user_id'],
      rating: json['rating'],
      description: json['description'],
      orderId: json['order_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
