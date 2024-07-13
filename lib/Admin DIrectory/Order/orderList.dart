import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Network Configuration/networkConfig.dart';
import 'orderModel.dart';


class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Order>> futureOrders;
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    futureOrders = fetchOrders();
  }

  Future<List<Order>> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiUrl}/order-list'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        if (jsonResponse != null) {
          return jsonResponse.map((order) => Order.fromJson(order)).toList();
        } else {
          throw Exception('Response was null');
        }
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<void> _refreshOrderList() async {
    setState(() {
      futureOrders = fetchOrders();
    });
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    final url = Uri.parse('${Config.apiUrl}/update-order-status/$orderId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'order_status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        print('Order status updated successfully');
        // Optionally, you can refresh the orders list after updating the status
        setState(() {
          futureOrders = fetchOrders();
        });
      } else {
        print('Failed to update order status: ${response.statusCode}');
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Error updating order status: $e');
    }
  }

  List<Order> filterOrders(List<Order> orders) {
    if (filter == 'All') {
      return orders;
    } else if (filter == 'Preparing') {
      return orders.where((order) => order.orderStatus == 'Preparing' || order.orderStatus == 'Delayed').toList();
    } else {
      return orders.where((order) => order.orderStatus == filter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrderList,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // colors: [Colors.lightBlue, Colors.red.shade50, Colors.white],
              colors: [Colors.blue.shade100, Colors.red.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilterButton(
                      text: 'All',
                      isSelected: filter == 'All',
                      onPressed: () {
                        setState(() {
                          filter = 'All';
                        });
                      },
                    ),
                    FilterButton(
                      text: 'Preparing',
                      isSelected: filter == 'Preparing',
                      onPressed: () {
                        setState(() {
                          filter = 'Preparing';
                        });
                      },
                    ),
                    FilterButton(
                      text: 'Completed',
                      isSelected: filter == 'Completed',
                      onPressed: () {
                        setState(() {
                          filter = 'Completed';
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Order>>(
                  future: futureOrders,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<Order> filteredOrders = filterOrders(snapshot.data!);
                      return ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          Order order = filteredOrders[index];
                          return OrderCard(
                            order: order,
                            onUpdateStatus: (String newStatus) {
                              _updateOrderStatus(order.id, newStatus);
                            },
                          );

                        },
                      );

                    }
                  },
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  FilterButton({
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue[800] : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.blue[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final Function(String) onUpdateStatus;

  OrderCard({required this.order, required this.onUpdateStatus});

  void _showUpdateOrderModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedStatus = order.orderStatus;
        return AlertDialog(
          title: Text('Update Order Status'),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            items: ['Preparing', 'Delayed', 'Completed'].map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                selectedStatus = newValue;
              }
            },
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update', style: TextStyle(color: Colors.black)),
              onPressed: () {
                onUpdateStatus(selectedStatus);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: order.orderStatus == 'Completed'
                        ? Colors.green
                        : order.orderStatus == 'Preparing'
                        ? Colors.yellow.shade800
                        : Colors.red,  // Default to red for 'Delayed' and any other status
                  ),
                  child: TextButton(
                    onPressed: () {
                      // Add functionality for the button here
                    },
                    child: Text(
                      order.orderStatus,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text('Customer: ${order.user.username}'), // Accessing customer name
            Text('Address: ${order.orderAddress}'),
            Text('${order.createdAt.toLocal()}'),
            Divider(),
            Column(
              children: order.orderProducts.map((product) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Product ID: ${product.product.id}'), // Accessing product ID
                        Text('${product.quantity} x RM${product.price.toStringAsFixed(2)}'),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text('Product Name: ${product.product.productName}'), // Accessing product name
                    Divider(),
                  ],
                );
              }).toList(),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'RM${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (order.orderStatus == 'Preparing' || order.orderStatus == 'Delayed')
                  ElevatedButton(
                    onPressed: () => _showUpdateOrderModal(context),
                    child: Text(
                      'Update Order',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildRecommendedItem(String title, String subtitle, String price) {
  return Card(
    child: ListTile(
      leading: Image.network(
        'https://via.placeholder.com/100', // Replace with actual image
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Icon(Icons.error);
        },
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(price, style: TextStyle(fontWeight: FontWeight.bold)),
    ),
  );
}
