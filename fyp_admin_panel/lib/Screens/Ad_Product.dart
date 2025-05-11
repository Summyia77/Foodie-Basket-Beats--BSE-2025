import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../Reuseable code/profile_data.dart';
class Add_Product extends StatefulWidget {


  @override
  State<Add_Product> createState() => _HomeState();
}

class _HomeState extends State<Add_Product> {
  final _formKey = GlobalKey<FormState>(); // Create a form key for validation
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _priceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _categoryController = TextEditingController();


  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryIdController.dispose();
    _imageUrlController.dispose();
    _priceController.dispose();
    _ratingController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("#FFA500"),
        title: Text('Add Product',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),

      ),
      body: Container(
        color: Colors.white,
        height: 800,
        child: SingleChildScrollView( // Allow content to scroll if it overflows
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey, // Assign form key
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text("Add New Food Items Here" ,style: TextStyle(fontSize: 23,color: Colors.red,fontWeight: FontWeight.bold),),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Product category',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Product Description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product description';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL in jpg formate',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an image URL';
                    }
                    // Basic URL validation (can be improved)
                    if (!Uri.parse(value).hasAbsolutePath) {
                      return 'Invalid image URL. Must be a valid web address.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number, // Allow decimals
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    try {
                      double.parse(value); // Attempt to parse as double
                    } catch (e) {
                      return 'Invalid price. Must be a number.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ratingController,
                  keyboardType: TextInputType.number, // Allow decimals
                  decoration: const InputDecoration(
                    labelText: 'Rating (0.0 - 5.0)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a rating';
                    }
                    try {
                      double rating = double.parse(value);
                      if (rating < 0.0 || rating > 5.0) {
                        return 'Invalid rating. Must be between 0.0 and 5.0.';
                      }
                    } catch (e) {
                      return 'Invalid rating. Must be a number.';
                    }
                    return null;
                  },
                ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: ElevatedButton(
              onPressed: () async {
                // 1. Generate unique product ID (UUID to Integer - robust parsing)
                String productIdString = Uuid().v4();
                List<String> parts = productIdString.split('-');
                int productId = 0;
                for (String part in parts) {
                  productId = (productId * 1000000 + int.parse(part, radix: 16)) % 500; // Modulo
                }
                productId = productId.abs();

                // 2. Add product data to Firestore, including the generated ID
                try {
                  await FirebaseFirestore.instance.collection('Store').doc(productId.toString()).set({
                    'category': _categoryController.text,
                    'description': _descriptionController.text,
                    'id': productId, // Store the integer product ID
                    'image': _imageUrlController.text,
                    'name': _nameController.text,
                    'price': _priceController.text,
                    'rating': _ratingController.text,
                    'orderCount':'0',
                  });

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Product added successfully!'),
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error adding product: $e'),
                  ));
                  print("Error adding product: $e");
                }
              },
              child: const Text('Add Product', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
