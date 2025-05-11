import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Reuseable code/profile_data.dart';

class Feedbacks extends StatefulWidget {
  const Feedbacks({super.key});

  @override
  State<Feedbacks> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Feedbacks> {
  final Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream =
  FirebaseFirestore.instance.collection('Feedback').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("#FFA500"),
        title: Text('Feedbacks',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),

      ),
      body: Container(
        width: 400,
        color: Colors.white, // Add white background
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding for the heading
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align heading to the left
            children: [
              Center(
                child: Text(
                  'Exciting Feedbacks Regarding App From Users ', // Heading text
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                  ),
                ),
              ),
              SizedBox(height: 18.0), // Add some space between heading and list
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _usersStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading...");
                  }

                  return Expanded( // Use Expanded to make the list scrollable
                    child: ListView(
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot<Map<String, dynamic>> document) {
                        Map<String, dynamic> data = document.data()!;
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(data['feedback']),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}