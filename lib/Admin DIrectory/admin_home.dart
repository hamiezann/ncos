import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Network Configuration/networkConfig.dart';
import 'Analytics/analyticsPage.dart';
import 'Analytics/bestSelling.dart';
import 'Order/orderList.dart';
import 'Order/orderModel.dart';
import 'Payment/paymentList.dart';
import 'Product/productList.dart';
import 'QR/qrPage.dart';
import 'Rating/ratingList.dart';


class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // int? totalSales = 0;
  String totalSales = '';
  double totalProfit = 0.0;
  // String bestProduct = '';

  List<Order> pendingDelayedOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
    _fetchPendingAndDelayedOrders();
  }

  Future<List<Order>> fetchPendingAndDelayedOrders() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiUrl}/orders/pending-delayed'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((order) => Order.fromJson(order)).toList();
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }


  Future<void> _fetchPendingAndDelayedOrders() async {
    try {
      final orders = await fetchPendingAndDelayedOrders();
      setState(() {
        pendingDelayedOrders = orders;
      });
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  Future<void> _fetchAnalyticsData() async {
    try {
      final sales = await AnalyticService.fetchTotalSales();
      final profit = await AnalyticService.fetchTotalProfit();
      // final products = await AnalyticService.fetchBestSellingProducts();

      setState(() {
        totalSales = sales;
        totalProfit = profit;
        // bestProduct = products.isNotEmpty ? products[0]['name'] : ''; // Assuming products is a list of maps
      });
    } catch (e) {
      print('Error fetching analytics data: $e');
      // Handle error
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('role');
      await prefs.remove('isLoggedIn');

      print('Logout successful');

      // Provide feedback to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout successful'),
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to splash screen and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(context, '/splashscreen', (route) => false);
    } catch (e) {
      print('Logout failed: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Logout Failed'),
          content: Text('An error occurred during logout. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Confirm Logout')),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    _logout(context); // Call logout function
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Logout', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.menu_open),
        //   onPressed: () {
        //     // Handle menu button press
        //   },
        // ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.0),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.asset('assets/logo.jpeg',)),
          ),  // Path to your logo image
        ),
        title: Text(
          'Hello Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded),
            onPressed: () {
              _confirmLogout(context);
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Analytics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildAnalyticsInfo('Total Sales ', '\RM${totalSales}'),
                  SizedBox(height: 5,),
                  _buildAnalyticsInfo('Total Profit ', '\RM${totalProfit.toStringAsFixed(2)}'),
                  // _buildAnalyticsInfo('Best Product Today', bestProduct),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>BestSellingProductsPage()),
                        );
                      },
                      child: Text('Best Selling Products',
                        style: TextStyle(color: Colors.black,),),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade100, Colors.red.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildCategoryIcons(context),
                        const SizedBox(
                          height: 40,
                          // width: 100,
                        ),
                        _buildQrCodeButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeButton() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.qr_code, size: 30, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QrScannerScreen()),
              );
            },
          ),
        ),
        SizedBox(height: 8), // Add some space between the button and the text
        Text(
          'Scan Order',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }


  Widget _buildCategoryIcons(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10.0,
      children: [
        _buildCategoryIcon(
          context,
          Icons.restaurant,
          'Menu',
          AdminMenuList(),
          // Colors.lightBlue.shade50,
          Colors.white,
        ),
        _buildCategoryIcon(
          context,
          Icons.add_chart_outlined,
          'Order',
          OrdersPage(),
          // Colors.pink.shade50, // Use a single Color here
          Colors.white,
        ),
        _buildCategoryIcon(
          context,
          Icons.menu_book_outlined,
          'Payment',
          PaymentPage(),
          Colors.white,
          // Colors.orange.shade50, // Use a single Color here
        ),
        _buildCategoryIcon(
          context,
          Icons.star_half_outlined,
          'Rating',
          AdminRatingListPage(),
          Colors.white,
          // Colors.lightBlue.shade50, // Use a single Color here
        ),
      ],
    );
  }


  Widget _buildCategoryIcon(
      BuildContext context,
      IconData icon,
      String label,
      Widget page,
      Color color, // Change to a single Color instead of a List of Colors
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color, // Use the single Color here
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.black),
            SizedBox(height: 10),
            Text(label, style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsInfo(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Container(
          padding: EdgeInsets.all(8.0),  // Add padding
          decoration: BoxDecoration(
            color: Colors.white,  // Background color
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),  // Rounded corners
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

      ],
    );
  }


}
