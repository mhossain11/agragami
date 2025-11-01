import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class UsersListScreen extends StatelessWidget {
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of users'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),

      body: StreamBuilder<QuerySnapshot>(
        // Filter করে শুধু role = "User"
        stream: usersCollection.where('role', isEqualTo: 'user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs;

          return Column(
            children: [
              Card(
                elevation: 3,
                color: Colors.red.shade50,
                child: SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Center(
                    child: Text(
                      'User Length:${users.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final user = doc.data() as Map<String, dynamic>;
                    final userDocId = doc.id; //
                    return Column(
                      children: [
                        Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(Icons.person, color: Colors.black87),
                              ),
                              title: Text(
                                user['name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoRow('ID', user['user_id']),
                                    _infoRow('Email', user['email']),
                                    _infoRow('Number', user['phone']),
                                    _infoRow('Birthdate', _formatBirthdate(user['birthdate'])),
                                    _infoRow('Address', _getAddress(user)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )

                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$label: ${value ?? 'N/A'}',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }



  String _formatBirthdate(dynamic birthdate) {
    try {
      DateTime date;

      if (birthdate is String) {
        // dd/MM/yy format handle করা
        date = DateFormat('d/M/yy').parse(birthdate);
      } else if (birthdate is Timestamp) {
        date = birthdate.toDate();
      } else {
        return 'N/A';
      }

      // শুধু দিন এবং মাস দেখানো
      return DateFormat('d MMM').format(date); // Example: "19 Jun"
    } catch (e) {
      return 'N/A';
    }
  }

  String _getAddress(Map<String, dynamic> user) {
    final address = user['address'];
    if (address == null || address.toString().trim().isEmpty) {
      return 'N/A';
    }
    return address.toString();
  }




}
