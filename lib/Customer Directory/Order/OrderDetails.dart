import 'package:flutter/material.dart';
import 'CustomerOrderModel.dart';

class OrderDetailsPage extends StatelessWidget {
  final CustomerOrder order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restaurant: ${order.restaurantName}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Order Date: ${order.orderDate}'),
            SizedBox(height: 8),
            Text('Rating: ${order.orderRate} stars'),
            SizedBox(height: 8),
            Text('Products: ${order.productCount}'),
            SizedBox(height: 8),
            Text('Total Price: \$${order.orderPrice.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            Text(
              'Products:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: order.products.length,
                itemBuilder: (context, index) {
                  final product = order.products[index];
                  return ListTile(
                    title: Text(product.productName),
                    subtitle: Text(product.description),
                    trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
