import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'buildBottomActionBar.dart';
import 'buildTransactionsList.dart';
import 'buildUserInfoCard.dart';

class BuildVerifiedUserContent extends StatefulWidget {
  BuildVerifiedUserContent({super.key,required this.currentUserId,
    required this.isUserVerified});
  bool isUserVerified;
  String currentUserId;
  @override
  State<BuildVerifiedUserContent> createState() => _BuildVerifiedUserContentState();
}

class _BuildVerifiedUserContentState extends State<BuildVerifiedUserContent> {

  void _resetUser() {
    setState(() {
      widget.isUserVerified = false;
      widget.currentUserId = '';
      // _userIdController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agragami Financial Report'),centerTitle: true,),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentUserId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Column(
              children: [
                BuildUserInfoCard(userData: {'name': 'User not found'},
                  currentUserId: widget.currentUserId,
                  isUserVerified: widget.isUserVerified,),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 60, color: Colors.red),
                        SizedBox(height: 10),
                        Text(
                          'User data not found',
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _resetUser,
                          child: Text('Enter Different User ID'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              // User Info Card
              BuildUserInfoCard(userData: userData,
                currentUserId:  widget.currentUserId,
                isUserVerified: widget.isUserVerified,),

              // Transactions List
              Expanded(
                child: BuildTransactionsList(currentUserId: widget.currentUserId,),
              ),

              // Bottom Action Bar
              BuildBottomActionBar(currentUserId: widget.currentUserId,),
            ],
          );
        },
      ),
    );
  }
}
