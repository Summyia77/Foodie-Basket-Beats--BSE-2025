import 'package:flutter/material.dart';

import '../Reuseable code/profile_data.dart';
import '../Reuseable code/search_data.dart';


void main() {
  runApp(Update_Product());
}

class Update_Product extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: hexStringToColor("#FFA500"),
          title: Text('Update Products',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),

        ),
        body: Container(
          margin: EdgeInsets.only(top: 27,bottom:27),
          child: Center(
              child: fetchStoreData(),
          ),
        ),
      ),
    );
  }
}
