class CustomerOrder {
  final String orderStatus;
  final String orderDate;
  final String orderAddress;
  final double orderPrice;
  final List<CustomerProduct> products;

  CustomerOrder({
    required this.orderStatus,
    required this.orderDate,
    required this.orderAddress,
    required this.orderPrice,
    required this.products,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      orderStatus: json['order_status'] ?? 'Unknown Status',
      orderDate: json['created_at'] ?? 'Unknown Date',
      orderAddress: json['order_address'] ?? 'Unknown Address',
      orderPrice: json['total_amount'] != null ? double.tryParse(json['total_amount']) ?? 0.0 : 0.0,
      products: (json['order_products'] as List<dynamic>?)
          ?.map((orderProductJson) => CustomerProduct.fromJson(orderProductJson['product']))
          .toList() ??
          [],
    );
  }
}

class CustomerProduct {
  final int id;
  final int categoryId;
  final String description;
  final double price;
  final String image;
  final double rating;
  final String productName;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerProduct({
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

  factory CustomerProduct.fromJson(Map<String, dynamic> json) {
    // Clean up the image URL if it contains a duplicate base URL
    String imageUrl = json['image'] ?? '';
    if (imageUrl.startsWith('http://192.168.0.8/storage/http://192.168.0.8/storage/')) {
      imageUrl = imageUrl.replaceFirst('http://192.168.0.8/storage/http://192.168.0.8/storage/', 'http://192.168.0.8/storage/');
    }

    return CustomerProduct(
      id: json['id'],
      categoryId: json['category_id'],
      description: json['description'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      image: imageUrl,
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0.0,
      productName: json['product_name'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }
}

