import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../Reuseable code/Credential_code.dart';
import '../Reuseable code/reusable_button.dart';
import 'Ad_Product.dart';
import 'Home.dart';

class Login extends StatefulWidget {

  @override
  State<Login> createState() => SignInState();
}

class SignInState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _usernamecontroller=TextEditingController();
    TextEditingController  _passwordcontroller=TextEditingController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:  SingleChildScrollView(
        child:Container(
          height: 800,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hexStringToColor("#000000"), // Black color
                hexStringToColor("#FF9400"), // Slightly darker shade of orange
                hexStringToColor("#FFA500"), // Base orange color
                hexStringToColor("#FFB733"), // Lighter shade of orange
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 160.0), // Adjust top padding as needed
                  child: Column(
                      children:<Widget>[Image.asset(
                        'Images/icon.png', // Replace with your image path
                        width: 200, // Adjust the width as needed
                        height: 200, // Adjust the height as needed
                      ),
                        reusabletextfield("Enter Username",Icons.person_outline, false, _usernamecontroller),
                        reusabletextfield("Enter Password",Icons.lock_outline, true, _passwordcontroller),
                        reusablebutton(context, true, (){

                            // Check if the user exists in the 'Admin' collection
                            FirebaseFirestore.instance
                                .collection('Admin')
                                .where('username', isEqualTo: _usernamecontroller.text)
                                .where('password', isEqualTo: _passwordcontroller.text)
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              if (querySnapshot.docs.isNotEmpty) {
                                // User exists in the 'Admin' collection
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => Home()));
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Invalid Credentials'),
                                      content: Text('Please enter valid admin credentials.'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            });

                        })
                      ]
                  ),
                ),
              ),
            ],
          ),
        ),
      ),);
  }
  Color hexStringToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }}