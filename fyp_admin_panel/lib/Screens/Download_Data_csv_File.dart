import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Import for web downloads
import 'dart:convert'; // Import for JSON encoding

class DownloadFirestoreDataJSON extends StatefulWidget {
  const DownloadFirestoreDataJSON({super.key});

  @override
  _DownloadFirestoreDataJSONState createState() => _DownloadFirestoreDataJSONState();
}

class _DownloadFirestoreDataJSONState extends State<DownloadFirestoreDataJSON> {
  Future<List<Map<String, dynamic>>> getFirestoreData(String collectionName) async {
    List<Map<String, dynamic>> data = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();

      for (var doc in querySnapshot.docs) {
        final docData = doc.data() as Map<String, dynamic>;
        data.add(docData);
      }
    } catch (e) {
      print('Error retrieving Firestore data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error retrieving Firestore data: $e')),
      );
    }
    return data;
  }

  String convertDataToJSON(List<Map<String, dynamic>> data) {
    return jsonEncode(data);
  }

  Future<void> saveJSON(String json, String filename) async {
    if (kIsWeb) {
      // Web-specific download
      final blob = html.Blob([json]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('JSON file downloaded: $filename')),
      );
    } else {
      // Mobile-specific storage and save
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          print("Storage permission not granted");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission not granted')),
          );
          return;
        }
      }

      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final file = File('${directory.path}/$filename');
          await file.writeAsString(json);
          print('JSON file saved to ${file.path}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('JSON file saved to ${file.path}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Error: External storage directory not found.')),
          );
        }
      } catch (e) {
        print('Error saving JSON file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving JSON file: $e')),
        );
      }
    }
  }

  Future<void> downloadFirestoreJSON(String collectionName, String filename) async {
    List<Map<String, dynamic>> data = await getFirestoreData(collectionName);
    if (data.isNotEmpty) {
      String json = convertDataToJSON(data);
      await saveJSON(json, filename);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Firestore Data JSON'),
      ),
      body: Center(
        child: SingleChildScrollView( // Added for scrollability on smaller screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => downloadFirestoreJSON('Store', 'store_data.json'),
                child: const Text('Download Store Data JSON'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => downloadFirestoreJSON('Users', 'users_data.json'),
                child: const Text('Download Users Data JSON'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => downloadFirestoreJSON('Orders', 'orders_data.json'),
                child: const Text('Download Orders Data JSON'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => downloadFirestoreJSON('SOrders', 'sorders_data.json'),
                child: const Text('Download SOrders Data JSON'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => downloadFirestoreJSON('Wishlist', 'wishlist_data.json'),
                child: const Text('Download Wishlist Data JSON'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => downloadFirestoreJSON('cateogories', 'categories_data.json'),
                child: const Text('Download Categories Data JSON'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => downloadFirestoreJSON('userInteractions', 'user_interactions_data.json'),
                child: const Text('Download User Interactions Data JSON'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => downloadFirestoreJSON('Feedback', 'feedback_data.json'),
                child: const Text('Download Feedback Data JSON'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => downloadFirestoreJSON('Cart', 'cart_data.json'),
                child: const Text('Download Cart Data JSON'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}