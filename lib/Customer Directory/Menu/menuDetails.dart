import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuDetailsPage extends StatelessWidget {
  final dynamic product;

  MenuDetailsPage({required this.product});

  int quantity = 1;

  void incrementQuantity() {
    quantity++;
  }

  void decrementQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  void addToCart(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // You can save the product details or handle cart logic here

    // Show a SnackBar to indicate item added to cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item added to cart'),
        duration: Duration(seconds: 2), // Adjust as needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
        backgroundColor: Colors.black, // Set app bar background color to black
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Set icon color to white
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white), // Set icon color to white
            onPressed: () {
              // Add to favorites logic
            },
          ),
        ],
      ),
      backgroundColor: Colors.black, // Set scaffold background color to black
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              product['image'] ?? 'https://via.placeholder.com/150',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove, color: Colors.white), // Set icon color to white
                  onPressed: () {
                    decrementQuantity();
                    // Add your logic here if needed
                  },
                ),
                Text(
                  quantity.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color to white
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white), // Set icon color to white
                  onPressed: () {
                    incrementQuantity();
                    // Add your logic here if needed
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              product['product_name'] ?? 'Unknown',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set text color to white
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product['price'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 20,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '5-15 Min', // Example text, replace with actual data
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${product['rating']?.toString() ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set text color to white
              ),
            ),
            SizedBox(height: 8),
            Text(
              product['description'] ?? 'No description',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Set text color to white
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => addToCart(context), // Call addToCart function on button press
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('Add to cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
