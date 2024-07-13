import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Network Configuration/networkConfig.dart';
import '../Cart/cartModel.dart';
import '../Cart/cartWidget.dart';

class MenuPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  MenuPage({
    required this.categoryId,
    required this.categoryName,
  });

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/products/category/${widget.categoryId}'));

    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.categoryName),
      ),
      backgroundColor: Colors.black, // Set scaffold background color to black
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: GridView.builder(
            shrinkWrap: true, // Added to prevent GridView from taking infinite height
            physics: NeverScrollableScrollPhysics(), // Disable GridView's scrolling
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.55, // Aspect ratio of the items
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final dynamic product;

  ProductCard({required this.product});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int quantity = 0;
  final CartService _cartService = CartService();

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
            child:
            Text(
              message,
              style: TextStyle(
                  fontSize: 20, color: Colors.white),)
        ),
        duration: Duration(seconds: 2), // Adjust duration as needed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900], // Set card background color to dark grey (simulating black)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
            child: Image.network(
              '${widget.product['image']}',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 140, // Adjust height as needed
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.all(8.0), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      widget.product['product_name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 14, // Increased font size
                        fontWeight: FontWeight.bold,
                        color: Colors.orange, // Set text color to orange
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\RM ${widget.product['price']}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white, // Set text color to white
                      ),
                    ),
                    Text(
                      widget.product['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white, // Set text color to white
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 4),
                QuantityAdjuster(
                  quantity: quantity,
                  onAdd: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  onRemove: () {
                    setState(() {
                      if (quantity > 0) quantity--;
                    });
                  },
                ),
                // SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    final cartItem = CartItem(
                      id: widget.product['id'],
                      imageUrl: widget.product['image'],
                      name: widget.product['product_name'],
                      price: double.parse(widget.product['price']),
                      quantity: quantity,
                    );
                    _cartService.addToCart(cartItem);

                    // Show Snackbar
                    _showSnackbar('${widget.product['product_name']} added to cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('Add to Cart'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuantityAdjuster extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  QuantityAdjuster({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          color: Colors.white,
          onPressed: onRemove,
        ),
        Text(
          quantity.toString(),
          style: TextStyle(color: Colors.white),
        ),
        IconButton(
          icon: Icon(Icons.add),
          color: Colors.white,
          onPressed: onAdd,
        ),
      ],
    );
  }
}
