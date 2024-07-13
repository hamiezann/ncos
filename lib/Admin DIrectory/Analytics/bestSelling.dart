import 'package:flutter/material.dart';
import 'analyticsPage.dart';

// import 'package:itt632_nashcafe/services/analyticService.dart';

class BestSellingProductsPage extends StatefulWidget {
  @override
  _BestSellingProductsPageState createState() => _BestSellingProductsPageState();
}

class _BestSellingProductsPageState extends State<BestSellingProductsPage> {
  Future<List<Map<String, dynamic>>>? _bestSellingProducts;
  String bestProduct = '';

  @override
  void initState() {
    super.initState();
    _fetchAndSetBestSellingProducts();
  }

  Future<void> _fetchAndSetBestSellingProducts() async {
    try {
      final products = await AnalyticService.fetchBestSellingProducts();
      setState(() {
        _bestSellingProducts = Future.value(products);
        bestProduct = products.isNotEmpty ? products[0]['product_name'] : 'No products found';
      });
    } catch (error) {
      setState(() {
        _bestSellingProducts = Future.error(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Best Selling Products'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context,'/admin-home');
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Top Best Selling Product: $bestProduct',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _bestSellingProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No best selling products found'));
                } else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: Image.network('${product['image']}', fit: BoxFit.cover),
                        ),
                        title: Text(product['product_name']),
                        subtitle: Text('Quantity Sold: ${product['quantity_sold']}'),
                        trailing: Text('Price: ${product['price']}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
