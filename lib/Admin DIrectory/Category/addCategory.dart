import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Network Configuration/networkConfig.dart';

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  String _categoryName = '';


  Future<void> _createCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final request = http.MultipartRequest('POST', Uri.parse('${Config.apiUrl}/create-category'));
    request.fields['category_name'] = _categoryName;


    final response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category created successfully')),
      );
      Navigator.pop(context, true); // Return to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Category'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context,'/admin-product-list');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Category Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the category name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _categoryName = value!;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createCategory,
                  child: Text('Create Category'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
