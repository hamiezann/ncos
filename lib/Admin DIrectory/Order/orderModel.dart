import 'package:flutter/foundation.dart';
import 'package:ncos/Admin%20DIrectory/Product/productModel.dart';
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


