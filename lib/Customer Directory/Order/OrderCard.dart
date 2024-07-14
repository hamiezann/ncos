import 'package:flutter/material.dart';
import 'OrderDetails.dart';
import 'CustomerOrderModel.dart';

class OrderCard extends StatelessWidget {
  final CustomerOrder order;
  final VoidCallback onTap;

  const OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(order: order),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderStatus,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(order.orderDate),
              SizedBox(height: 8),
              // Row(
              //   children: List.generate(
              //     5,
              //         (index) => Icon(
              //       index < order.products ? Icons.star : Icons.star_border,
              //       color: Colors.orange,
              //       size: 20,
              //     ),
              //   ),
              // ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Products: ${order.products.length}'),
                  Spacer(),
                  Text('Order Price: \RM${order.orderPrice.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
