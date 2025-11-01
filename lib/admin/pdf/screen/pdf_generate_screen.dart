import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';
import '../service/pdf_service.dart';
import 'buildUserIdInputSection.dart';

class UserMoneyScreen extends StatefulWidget {
  const UserMoneyScreen({super.key});

  @override
  State<UserMoneyScreen> createState() => _UserMoneyScreenState();
}

class _UserMoneyScreenState extends State<UserMoneyScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agragami Financial Report'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(child: BuildUserIdInputSection()),
    );
  }


}