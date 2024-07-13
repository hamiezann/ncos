
class CartItem {
  final int id;
  final String imageUrl;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrl': imageUrl,
    'name': name,
    'price': price,
    'quantity':quantity,
  };

  static CartItem fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] ?? 0,
    imageUrl: json['imageUrl'] ?? '',
    name: json['name']  ?? '',
    price: json['price'] ?? 0.0,
    quantity: json['quantity'] ??  1,
  );
}