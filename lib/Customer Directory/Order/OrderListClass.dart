import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ncos/Network%20Configuration/networkConfig.dart';
import 'CustomerOrderModel.dart';
import 'OrderCard.dart';
import 'OrderDetails.dart';

class OrdersList extends StatelessWidget {
  final String orderType;
  final int userId;

  const OrdersList({
    required this.orderType,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CustomerOrder>>(
      future: fetchOrders(orderType, userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final orders = snapshot.data ?? [];
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return OrderCard(
              order: order,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(order: order),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<CustomerOrder>> fetchOrders(String orderType, int userId) async {
    final String apiUrl = '${Config.apiUrl}/orders/$userId/$orderType';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      Iterable jsonList = jsonDecode(response.body);
      return jsonList.map((model) => CustomerOrder.fromJson(model)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
