import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fyp_admin_panel/Screens/Ad_Product.dart';
import 'package:fyp_admin_panel/Screens/Orders.dart';
import 'package:fyp_admin_panel/Screens/Update_Product.dart';
import 'package:fyp_admin_panel/Screens/Download_Data_csv_File.dart';

import 'Login.dart';
import 'Feedbacks.dart';

class Home extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> {
  //,DownloadFirestoreDataJSON()
  List<Widget> _screens = [Add_Product(), Update_Product(), Feedbacks(), Orders(),DownloadFirestoreDataJSON()];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: IndexedStack( // Efficiently switch between screens
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        buttonBackgroundColor: Colors.black,
        color: hexStringToColor("#FFA500"), // Adjust color preference
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        height: 50, // Set custom height

        items: [
          Icon(Icons.add, size: 20, color: Colors.white),
          Icon(Icons.food_bank, size: 20, color: Colors.white),
          Icon(Icons.reviews, size: 20, color: Colors.white),
          Icon(Icons.card_travel, size: 20, color: Colors.white),
        // Icon(Icons.download, size: 20, color: Colors.white),


        ],

        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}