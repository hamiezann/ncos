import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Network Configuration/networkConfig.dart';
import 'Cart/cartPage.dart';
import 'Maps/map.dart';
import 'Menu/menuList.dart';


class CustomerHomePage extends StatefulWidget {
  @override
  _CustomerHomePageState createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  Future<void> _logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('role');
      await prefs.remove('isLoggedIn');

      print('Logout successful');

      Navigator.pushReplacementNamed(context, '/splashscreen');
    } catch (e) {
      print('Logout failed: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Logout Failed'),
          content: Text(
              'An error occurred during logout. Please try again later.'),
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

  late Future<Map<String, dynamic>> _data;

  @override
  void initState() {
    super.initState();
    _data = fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    final categoriesResponse = await http
        .get(Uri.parse('${Config.apiUrl}/category-list'));
    final productsResponse =
    await http.get(Uri.parse('${Config.apiUrl}/product-list'));

    if (categoriesResponse.statusCode == 200 &&
        productsResponse.statusCode == 200) {
      final categories = json.decode(categoriesResponse.body);
      final products = json.decode(productsResponse.body);
      return {'categories': categories, 'products': products};
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _viewAllProducts(BuildContext context, int categoryId,
      String categoryName, List<dynamic> products) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuPage(
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ),
    );
  }

  // void _goToCartPage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => CartPage(
  //         imageUrl: 'https://via.placeholder.com/100',
  //         title: 'Sample Product',
  //         subtitle: 'Sample Product Description',
  //         price: '\$10.00',
  //         quantity: 1,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  'Welcome',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,  color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  onPressed: () {
                    // _goToCartPage(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()), // Navigate to CustomerHomePage
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () => _logout(context),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share Happiness',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Buy 1 Get 1',
                            style: TextStyle(fontSize: 16, color: Colors.pink),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Handle find out more button press
                            },
                            child: Text('Find out more'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange, // Orange theme
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Image.network(
                        'https://via.placeholder.com/100',
                        // Replace with actual image URL
                        width: 100,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                FutureBuilder<Map<String, dynamic>>(
                  future: _data,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Failed to load data'));
                    } else {
                      final categories = snapshot.data?['categories'] ?? [];
                      final products = snapshot.data?['products'] ?? [];
                      return _buildCategorySection(
                          context, categories, products);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
            // Navigate to home page if necessary
              break;
            case 1:
              Navigator.pushReplacementNamed(
                  context,
                  // MaterialPageRoute(builder: (context) => MapScreen()),
                  '/map'
              );
              break;
            case 2:
              Navigator.pushReplacementNamed(
                  context,
                  '/order-history'
                // MaterialPageRoute(builder: (context) => OrdersHistoryPage()),
              ); // Navigate to OrdersPage
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile'); // Navigate to profile page
              break;
          }
        },
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, List<dynamic> categories,
      List<dynamic> products) {
    final categoriesWithProducts = categories.where((category) {
      final categoryId = category['id'];
      return products.any((product) => product['category_id'] == categoryId);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoriesWithProducts.map<Widget>((category) {
        final categoryId = category['id'];
        final categoryName = category['category_name'] ?? 'Unknown';
        final categoryProducts = products
            .where((product) => product['category_id'] == categoryId)
            .take(3) // Take only 3 products per category
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color to white
                  ),
                ),
                TextButton(
                  onPressed: () => _viewAllProducts(
                      context, categoryId, categoryName, products),
                  child: Text(
                    'View All',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categoryProducts
                    .map((product) => _buildProductWidget(context, product))
                    .toList(),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildProductWidget(BuildContext context, dynamic product) {
    return GestureDetector(
      onTap: () {
        // Handle tapping on product
      },
      child: Container(
        width: 140,
        margin: EdgeInsets.symmetric(horizontal: 8), // Add spacing between products
        decoration: BoxDecoration(
          color: Colors.grey[900], // Set background color to orange
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              product['image'] ?? 'https://via.placeholder.com/150',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8),
            Text(
              product['product_name'] ?? 'Unknown Product',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange, // Set text color to black
              ),
            ),
          ],
        ),
      ),
    );
  }
}
