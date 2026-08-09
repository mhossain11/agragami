import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
   ContactScreen({super.key,required this.color});
  Color color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Contact Us'),
        centerTitle: true,
        backgroundColor: color,
      ),
      body: Center(
          child: Image.asset('assets/images/contact.png')),
    );
  }
}
