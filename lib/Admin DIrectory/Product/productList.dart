import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../Network Configuration/networkConfig.dart';
import '../Category/addCategory.dart';
import '../Category/editCategory.dart';
import 'addProduct.dart';
import 'editProduct.dart';

class AdminMenuList extends StatefulWidget {
  const AdminMenuList({Key? key}) : super(key: key);

  @override
  State<AdminMenuList> createState() => _AdminMenuListState();
}

class _AdminMenuListState extends State<AdminMenuList> {
  List<dynamic> productList = [];
  List<dynamic> categoryList = []; // Add category list

  @override
  void initState() {
    super.initState();
    _menuList(); // Fetch products
    _categoryList(); // Fetch categories
  }

  Future<void> _menuList() async {
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/product-list'),
    );

    if (response.statusCode == 200) {
      setState(() {
        productList = jsonDecode(response.body);
      });
    } else {
      print('Failed to load products: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load products. Please try again later.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _categoryList() async {
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/category-list'),
    );

    if (response.statusCode == 200) {
      setState(() {
        categoryList = jsonDecode(response.body);
      });
    } else {
      print('Failed to load categories: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load categories. Please try again later.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deleteCategory(int categoryId) async {
    final response = await http.delete(
      Uri.parse('${Config.apiUrl}/delete-category/$categoryId'),
    );

    if (response.statusCode == 204) {
      setState(() {
        categoryList.removeWhere((category) => category['id'] == categoryId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category deleted successfully.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      print('Failed to delete category: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete category. Please try again later.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog(int categoryId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this category?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCategory(categoryId);
              },
              child: Text('Delete'),
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
        centerTitle: true,
        title: Text('Menu', textAlign: TextAlign.center,),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context,'/admin-home');
          },
        ),
        actions: [
          // Text(
          //   'Add',
          //   style: TextStyle(color: Colors.white, fontSize: 16),
          // ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateProductPage()),
              );
            },
            icon: Icon(Icons.add),
            tooltip: 'Add Product',
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddCategoryPage()),
              );
            },
            icon: Icon(Icons.category),
            tooltip: 'Add Category',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue, Colors.red.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 16.0), // Space below the buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      textAlign: TextAlign.center,

                      'Products',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: productList.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        var product = productList[index];
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => EditProductPage(product['id'])),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: product['image'] != null && product['image'].isNotEmpty
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        product['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return Icon(Icons.error);
                                        },
                                      ),
                                    )
                                        : Placeholder(),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['product_name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          product['description'],
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          '\$${product['price']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => EditProductPage(product['id'])),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [Colors.red.shade50, Colors.white],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 24.0,
                                      ),
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(product['id']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0), // Space between products and categories
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: categoryList.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        var category = categoryList[index];
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              // Implement category details or edit page navigation
                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => EditCategoryPage(category['id'])),
                              // );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.category),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: Text(
                                      category['category_name'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      // Implement edit functionality for category
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => EditCategoryPage(category['id'])),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    // icon: Icon(Icons.delete),
                                    icon: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          colors: [Colors.red.shade50, Colors.white],
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 24.0,
                                      ),
                                    ),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(category['id']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
