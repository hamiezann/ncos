class Product {
  final int id;
  final int categoryId;
  final String description;
  final double price;
  final String image;
  final double rating;
  final String productName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.categoryId,
    required this.description,
    required this.price,
    required this.image,
    required this.rating,
    required this.productName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // print('Parsing Product from JSON: $json');

    return Product(
      id: json['id'],
      categoryId: json['category_id'],
      description: json['description'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      image: json['image'] ?? '',
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0.0,
      productName: json['product_name'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }
}
