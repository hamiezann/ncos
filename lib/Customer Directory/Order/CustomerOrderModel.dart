
import 'package:ncos/Admin%20DIrectory/Product/productModel.dart';

class CustomerOrder {
  final String restaurantName;
  final String orderDate;
  final int orderRate;
  final int productCount;
  final double orderPrice;
  final List<Product> products; // Add a list of Product objects

  CustomerOrder({
    required this.restaurantName,
    required this.orderDate,
    required this.orderRate,
    required this.productCount,
    required this.orderPrice,
    required this.products, // Include products in the constructor
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      restaurantName: json['order_status'] ?? 'Unknown Restaurant',
      orderDate: json['created_at'] ?? 'Unknown Date',
      orderRate: json['orderRate'] ?? 0,
      productCount: json['productCount'] ?? 0,
      orderPrice: json['total_amount'] != null ? double.tryParse(json['total_amount']) ?? 0.0 : 0.0,
      products: (json['products'] as List<dynamic>?)
          ?.map((productJson) => Product.fromJson(productJson as Map<String, dynamic>))
          .toList() ??
          [], // Parse products from JSON
    );
  }
}
