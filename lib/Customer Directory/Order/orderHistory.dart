import 'package:flutter/material.dart';
import '../Maps/map.dart';
import '../customer_home.dart';

class OrdersHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Orders'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Past Orders'),
              Tab(text: 'Upcoming Orders'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrdersList(orderType: 'Past'),
            OrdersList(orderType: 'Upcoming'),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
          onTap: (int index) {
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerHomePage()), // Navigate to CustomerHomePage
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapScreen()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersHistoryPage()), // Navigate to OrdersPage
                );
                break;
              case 3:
                Navigator.pushNamed(
                    context, '/profile'); // Navigate to profile page
                break;
            }
          },
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String orderType;

  const OrdersList({required this.orderType});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        OrderCard(
          restaurantName: 'Home - Baker Street',
          orderDate: 'Jan 24, 2020 | 20:04',
          orderRate: 4,
          productCount: 3,
          orderPrice: 30.75,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(
                  restaurantName: 'Home - Baker Street',
                  orderDate: 'Jan 24, 2020 | 20:04',
                  orderRate: 4,
                  productCount: 3,
                  orderPrice: 30.75,
                ),
              ),
            );
          },
        ),
        OrderCard(
          restaurantName: 'Home - Elm Street',
          orderDate: 'Jan 13, 2020 | 13:16',
          orderRate: 5,
          productCount: 5,
          orderPrice: 45.99,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(
                  restaurantName: 'Home - Elm Street',
                  orderDate: 'Jan 13, 2020 | 13:16',
                  orderRate: 5,
                  productCount: 5,
                  orderPrice: 45.99,
                ),
              ),
            );
          },
        ),
        OrderCard(
          restaurantName: 'Home - Maple Street',
          orderDate: 'Jan 2, 2020 | 16:32',
          orderRate: 3,
          productCount: 2,
          orderPrice: 22.50,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(
                  restaurantName: 'Home - Maple Street',
                  orderDate: 'Jan 2, 2020 | 16:32',
                  orderRate: 3,
                  productCount: 2,
                  orderPrice: 22.50,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class OrderCard extends StatelessWidget {
  final String restaurantName;
  final String orderDate;
  final int orderRate;
  final int productCount;
  final double orderPrice;
  final VoidCallback? onTap;

  const OrderCard({
    required this.restaurantName,
    required this.orderDate,
    required this.orderRate,
    required this.productCount,
    required this.orderPrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurantName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(orderDate),
              SizedBox(height: 8),
              Row(
                children: List.generate(
                  5,
                      (index) => Icon(
                    index < orderRate ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('Products: $productCount'),
                  Spacer(),
                  Text('Order Price: \$${orderPrice.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailsPage extends StatelessWidget {
  final String restaurantName;
  final String orderDate;
  final int orderRate;
  final int productCount;
  final double orderPrice;

  const OrderDetailsPage({
    required this.restaurantName,
    required this.orderDate,
    required this.orderRate,
    required this.productCount,
    required this.orderPrice,
  });

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
              'Restaurant: $restaurantName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Order Date: $orderDate'),
            SizedBox(height: 8),
            Text('Rating: $orderRate stars'),
            SizedBox(height: 8),
            Text('Products: $productCount'),
            SizedBox(height: 8),
            Text('Total Price: \$${orderPrice.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
