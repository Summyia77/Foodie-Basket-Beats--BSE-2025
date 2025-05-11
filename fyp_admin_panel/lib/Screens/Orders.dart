import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Order {
  final String address;
  final String name;
  final String price;
  final int quantity;
  final String id;
  final String receiverName;
  final String productid;
  final String status;
  final String userId;
  final String description;
  final String image;
  final List<Map<String, dynamic>>? items;

  Order({
    required this.address,
    required this.name,
    required this.price,
    required this.quantity,
    required this.id,
    required this.receiverName,
    required this.productid,
    required this.status,
    required this.userId,
    required this.description,
    required this.image,
    this.items,
  });

  factory Order.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Order(
      address: data['address'] ?? 'None',
      name: data['name'] ?? 'None',
      price: data['price'] ?? 'None',
      quantity: data['quantity'] ?? 0,
      id: snapshot.id,
      receiverName: data['receiverName'] ?? 'None',
      productid: data['productid'] ?? 'None',
      status: data['status'] ?? 'None',
      userId: data['userId'] ?? 'None',
      description: data['description'] ?? 'None',
      image: data['imageUrl'] ?? 'None',
      items: (data['items'] as List<dynamic>?)?.map((item) => item as Map<String, dynamic>).toList(),
    );
  }
}

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("#FFA500"),
        title: const Text(
          'Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(right: 7.0, top: 5, bottom: 10, left: 7),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Orders').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = snapshot.data!.docs.map((doc) => Order.fromFirestore(doc)).toList();

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('SOrders').snapshots(),
                builder: (context, sSnapshot) {
                  if (sSnapshot.hasError) {
                    return Center(child: Text('Error: ${sSnapshot.error}'));
                  }

                  if (!sSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sOrders = sSnapshot.data!.docs.map((doc) => Order.fromFirestore(doc)).toList();
                  final allOrders = orders + sOrders;

                  if (allOrders.isEmpty) {
                    return const Center(
                      child: Text(
                        "There are no orders yet.",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: allOrders.length,
                    itemBuilder: (context, index) {
                      final order = allOrders[index];
                      return buildOrderItem(order);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildOrderItem(Order order) {
    double totalPrice = 0;
    if (order.items != null && order.items!.isNotEmpty) {
      for (var item in order.items!) {
        double? parsedPrice = double.tryParse(item['price'].replaceAll(RegExp(r'[^\d\.]'), ''));
        if (parsedPrice != null) {
          totalPrice += parsedPrice * item['quantity'];
        }
      }
    } else if (order.price != 'None') {
      double? parsedPrice = double.tryParse(order.price.replaceAll(RegExp(r'[^\d\.]'), ''));
      if (parsedPrice != null) {
        totalPrice = parsedPrice * order.quantity;
      }
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            Text('Address: ${order.address}'),
            Text('Receiver: ${order.receiverName}'),
            Text('Total: Rs. ${totalPrice.toStringAsFixed(2)}'),
            if (order.items != null && order.items!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items!.length,
                itemBuilder: (context, itemIndex) {
                  final item = order.items![itemIndex];
                  return buildOrderItemDetails(item);
                },
              ),
            ] else ...[
              Text('Product: ${order.name}'),
              Text('Price: Rs. ${order.price}'),
              Text('Quantity: ${order.quantity}'),
              if (order.image != 'None') ...[
                const SizedBox(height: 8),
                Image.network(
                  order.image,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, object, stackTrace) => const Center(child: Text("Image Not Available")),
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ],
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    cancelOrder(order.id);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    minimumSize: const Size(80, 30),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderItemDetails(Map<String, dynamic> item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['image'] != null)
              Image.network(
                item['image'],
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, object, stackTrace) => const Center(child: Text("Image Not Available")),
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            Text('Name: ${item['name'] ?? 'N/A'}'),
            Text('Price: ${item['price'] ?? 'N/A'}'),
            Text('Quantity: ${item['quantity'] ?? 'N/A'}'),
            Text('Product ID: ${item['productId'] ?? 'N/A'}'),
          ],
        ),
      ),
      color: Colors.orange[100],
    );
  }



  Future<void> cancelOrder(String orderId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check and delete from 'Orders' collection
      DocumentReference orderRef = firestore.collection('Orders').doc(orderId);
      DocumentSnapshot orderSnapshot = await orderRef.get();
      if (orderSnapshot.exists) {
        await orderRef.delete();
        print('Order with ID $orderId deleted from Orders.');
      }

      // Check and delete from 'SDorders' collection
      DocumentReference sdOrderRef = firestore.collection('SOrders').doc(orderId);
      DocumentSnapshot sdOrderSnapshot = await sdOrderRef.get();
      if (sdOrderSnapshot.exists) {
        await sdOrderRef.delete();
        print('Order with ID $orderId deleted from SOrders.');
      }

      if (!orderSnapshot.exists && !sdOrderSnapshot.exists) {
        print('Order with ID $orderId not found in either collection.');
      }


    } catch (e) {
      print('Error canceling order: $e');
    }
  }

  Color hexStringToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF" + hex;
    }
    return Color(int.parse(hex, radix: 16));
  }
}