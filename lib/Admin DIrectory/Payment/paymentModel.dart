import '../Order/orderModel.dart';


class Payment {
  final int id;
  final double totalPrice;
  final String paymentMethod;
  final int transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Order> orders;

  Payment({
    required this.id,
    required this.totalPrice,
    required this.paymentMethod,
    required this.transactionId,
    required this.createdAt,
    required this.updatedAt,
    required this.orders,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // print('Parsing Payment from JSON: $json');

    return Payment(
      id: json['id'] ?? 0,
      totalPrice: json['total_price'] != null ? double.parse(json['total_price'].toString()) : 0.0,
      paymentMethod: json['payment_method'] ?? '',
      transactionId: json['transaction_id'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      orders: (json['orders'] as List?)
          ?.map((orderJson) => Order.fromJson(orderJson))
          .toList() ?? [],
    );
  }
}
