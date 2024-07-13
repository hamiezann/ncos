import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Network Configuration/networkConfig.dart';

class EditCategoryPage extends StatefulWidget {
  final int categoryId;
  EditCategoryPage(this.categoryId);

  @override
  _EditCategoryPageState createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  String _categoryName = '';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
  }

  Future<void> _fetchCategoryDetails() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiUrl}/category/${widget.categoryId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categoryName = data['category_name'];
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load category details. Please try again.';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _hasError = true;
        _errorMessage = 'An error occurred. Please check your internet connection and try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _editCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final request = http.MultipartRequest('POST', Uri.parse('${Config.apiUrl}/edit-category/${widget.categoryId}'));
    request.fields['category_name'] = _categoryName;

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category edited successfully')),
      );
      Navigator.pop(context, true); // Return to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit category')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Existing Category'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context,'/admin-product-list');
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchCategoryDetails,
              child: Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: _categoryName,
                  decoration: InputDecoration(labelText: 'New Category Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the new category name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _categoryName = value!;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _editCategory,
                  child: Text('Edit Category'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
