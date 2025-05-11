import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';


StreamBuilder<QuerySnapshot<Object?>> fetchStoreData() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection("Store").snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        final storeItems = snapshot.data!.docs;
        return GridView.count(
          crossAxisCount: 2, // Two columns in the grid
          childAspectRatio: 0.7, // Adjust aspect ratio for better card height
          mainAxisSpacing: 10.0, // Add spacing between rows
          crossAxisSpacing: 10.0, // Add spacing between columns
          children: List.generate(
            storeItems.length,
                (index) => Container(
              margin: EdgeInsets.all(10.0), // Consistent margin around the entire container
              child: Card(
                elevation: 2.0, // Add card elevation for a subtle shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners for cards
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding for better spacing
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200.0,
                        height: 190.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    storeItems[index]['image'],
                                    fit: BoxFit.cover,
                                    width: 140.0,
                                    height: 90.0,
                                  ),
                                ),
                                SizedBox(height: 6.0),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    storeItems[index]['name'],
                                    style: const TextStyle(fontSize: 13.0),
                                  ),
                                ),
                                Text("Rs." + storeItems[index]['price'].toString(), style: TextStyle(fontSize: 13.0)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showEditPopup(context, storeItems[index]);
                                      },
                                      icon: Icon(Icons.edit, color: Colors.blueAccent),
                                    ),
                                    SizedBox(width: 10.0),
                                    IconButton(
                                      onPressed: () {
                                        deleteItem(storeItems[index].id);
                                      },
                                      icon: Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

void deleteItem(String itemId) {
  // Implement your delete logic here
  print("Deleting item with ID: $itemId");
  FirebaseFirestore.instance.collection("Store").doc(itemId).delete();
}

void showEditPopup(BuildContext context, DocumentSnapshot<Object?> doc) async {
  final nameController = TextEditingController(text: doc['name']);
  final categoryController = TextEditingController(text: doc['category']);
  final imageController = TextEditingController(text: doc['image']);
  final docidController = TextEditingController(text: doc.id);
  final idController = TextEditingController(text: "id");
  final ratingController = TextEditingController(text: doc['rating'].toString());
  final priceController = TextEditingController(text: doc['price'].toString());
  final descriptionController = TextEditingController(text: doc['description']);
  final orderCountController = TextEditingController(text: doc['orderCount'].toString());

  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Edit Item'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: orderCountController,
                  keyboardType: TextInputType.number, // Allow decimals
                  decoration: InputDecoration(labelText: 'order Count'),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) => value!.isEmpty ? 'Category is required' : null,
                ),
                TextFormField(
                  controller: idController,

                  decoration: InputDecoration(labelText: 'Id'),
                ),
                TextFormField(
                  controller: imageController,
                  decoration: InputDecoration(labelText: 'Image URL in jpg formate'),
                  validator: (value) => Uri.tryParse(value!) == null ? 'Invalid image URL' : null,
                ),
                TextFormField(
                  controller: descriptionController,

                  decoration: InputDecoration(labelText: 'Descrption'),
                ),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number, // Allow decimals
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextFormField(
                  controller: ratingController,

                  decoration: InputDecoration(labelText: 'Rating'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.text = doc['name'];
              categoryController.text = doc['category'];
              imageController.text = doc['image'];
              idController.text = doc['id'].toString();
              descriptionController.text = doc['description'];
              priceController.text = doc['price'].toString();
              ratingController.text = doc['rating'].toString();
              orderCountController.text = doc['orderCount'].toString();

              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await FirebaseFirestore.instance
                    .collection('Store')
                    .doc(doc.id)
                    .update({
                  'name': nameController.text,
                  'category': categoryController.text,
                  'image': imageController.text,
                  'description': descriptionController.text,
                  'price': priceController.text,
                  'rating': ratingController.text,
                  'id': idController.text,
                  'orderCount': orderCountController.text,

                });
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}




