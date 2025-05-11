import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/Screens/Home.dart';
import 'package:fyp_admin_panel/Screens/Login.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:fyp_admin_panel/Screens/Update_Product.dart';
import 'Screens/Download_Data_csv_File.dart';
import 'Screens/Feedbacks.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: DownloadFirestoreDataJSON(),
    );
  }
}
