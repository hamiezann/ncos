import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../Network Configuration/networkConfig.dart';

class EditProductPage extends StatefulWidget {
  final int productId;
  EditProductPage(this.productId);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  String _description = '';
  String _price = '';
  String _productCost = '';
  int? _categoryId = 1;
  File? _image;
  String _rating = '';
  String? _imageUrl;
  bool _isLoading = true;

  Map<String, int> categoryItems = {
    'Coffee': 1,
    'Sandwiches': 2,
    'Desserts': 3,
  };

  List<dynamic> category = [];

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _categoryList();
  }

  Future<void> _categoryList() async {
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/category-list'),
    );
    if (response.statusCode == 200) {
      setState(() {
        category = jsonDecode(response.body);
        // Set the initial category id to the first category in the list if available
        if (category.isNotEmpty) {
          _categoryId = category[0]['id'] as int?;
        }
      });
    } else {
      print('Failed to load category: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load category. Please try again later.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _fetchProductDetails() async {
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/product/${widget.productId}'),
    );

    if (response.statusCode == 200) {
      final product = jsonDecode(response.body);
      setState(() {
        _productName = product['product_name'];
        _description = product['description'];
        _price = product['price'].toString();
        _productCost = product['product_cost'].toString();
        _categoryId = product['category_id'];
        _rating = product['rating'].toString();
        _imageUrl = product['image'];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load product details.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _editProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Config.apiUrl}/edit-product/${widget.productId}'),
    );
    request.fields['product_name'] = _productName;
    request.fields['description'] = _description;
    request.fields['price'] = _price;
    request.fields['product_cost'] = _productCost;
    request.fields['category_id'] = _categoryId.toString();
    request.fields['rating'] = _rating;

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product updated successfully')),
      );
      Navigator.pop(context, true); // Return to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product')),
      );
      print('Failed to update product: $responseBody');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context,'/admin-product-list');
          },
        ),
      ),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: _productName,
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _productName = value!;
                  },
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
                DropdownButtonFormField<int>(
                  value: _categoryId,
                  decoration: InputDecoration(labelText: 'Category'),
                  items: category.map<DropdownMenuItem<int>>((category) {
                    return DropdownMenuItem<int>(
                      value: category['id'] as int,
                      child: Text(category['category_name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoryId = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _rating,
                  decoration: InputDecoration(labelText: 'Rating'),
                  onSaved: (value) {
                    _rating = value!;
                  },
                ),
                TextFormField(
                  initialValue: _price,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _price = value!;
                  },
                ),
                TextFormField(
                  initialValue: _productCost,
                  decoration: InputDecoration(labelText: 'Product Cost'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the product cost';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _productCost = value!;
                  },
                ),
                SizedBox(height: 20),
                _imageUrl != null && _image == null
                    ? Image.network(_imageUrl!)
                    : _image != null
                    ? Image.file(_image!)
                    : Text('No image selected.'),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _editProduct,
                  child: Text('Confirm Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
