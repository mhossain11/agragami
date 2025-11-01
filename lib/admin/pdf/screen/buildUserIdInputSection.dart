import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'buildVerifiedUserContent.dart';

class BuildUserIdInputSection extends StatefulWidget {
  const BuildUserIdInputSection({super.key});

  @override
  State<BuildUserIdInputSection> createState() => _BuildUserIdInputSectionState();
}

class _BuildUserIdInputSectionState extends State<BuildUserIdInputSection> {
  final TextEditingController _userIdController = TextEditingController();
  bool _isLoading = false;
  String _currentUserId = '';
  bool _isUserVerified = false;

  Future<void> _verifyUserAndLoadData() async {
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a user ID')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if user exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _currentUserId = userId;
          _isUserVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User verified successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BuildVerifiedUserContent(
              currentUserId: _currentUserId,
              isUserVerified: _isUserVerified,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found. Please check the user ID.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying user: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter User Doc ID to Generate Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please enter the user document ID to access financial data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'User Document ID',
                hintText: 'Enter user document ID...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                suffixIcon: _userIdController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _userIdController.clear();
                    setState(() {});
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: Icon(Icons.verified_user),
                label: Text(
                  'Verify User & Generate Report',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: _userIdController.text.trim().isEmpty
                    ? null
                    : _verifyUserAndLoadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Note: You need a valid user document ID from Firebase',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
