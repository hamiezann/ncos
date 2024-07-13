import 'package:flutter/foundation.dart';
import '../Payment/paymentModel.dart';



class Order {
  final int id;
  final int userId; // Assuming you have userId directly in Order
  final String orderStatus;
  final double totalAmount;
  final String orderAddress;
  final DateTime createdAt;
  final List<OrderProduct> orderProducts;
  final Payment payment;
  final User user; // Add user property here

  Order({
    required this.id,
    required this.userId,
    required this.orderStatus,
    required this.totalAmount,
    required this.orderAddress,
    required this.createdAt,
    required this.orderProducts,
    required this.payment,
    required this.user,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // print('Parsing Order from JSON: $json');

    return Order(
      id: json['id'],
      userId: json['user_id'],
      orderStatus: json['order_status'] ?? '',
      totalAmount: json['total_amount'] != null ? double.parse(json['total_amount'].toString()) : 0.0,
      orderAddress: json['order_address'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      orderProducts: (json['order_products'] as List?)
          ?.map((product) => OrderProduct.fromJson(product))
          .toList() ?? [],
      payment: Payment.fromJson(json['payment'] ?? {}),
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}


class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final String address;
  final String contactNumber;
  final DateTime emailVerifiedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.address,
    required this.contactNumber,
    required this.emailVerifiedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      address: json['address'],
      contactNumber: json['contact_number'],
      emailVerifiedAt: DateTime.parse(json['email_verified_at']),
    );
  }
}

class OrderProduct {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final Product product; // Assuming Product model is defined similarly

  OrderProduct({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      // price: double.parse(json['price']),
      price: json['price'] != null ? double.parse(json['price']) : 0.0,
      product: Product.fromJson(json['product']),
    );
  }
}

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

