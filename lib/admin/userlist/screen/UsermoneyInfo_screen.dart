import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../service/userlist_service.dart';

class UserMoneyInfoScreen extends StatelessWidget {
  final String userId;
  final String name;
  final String email;

  final UserListService _userListService = UserListService();

  UserMoneyInfoScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('userId: $userId');

    return Scaffold(
      appBar: AppBar(title: const Text('User Money List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _userListService.getMoneyListByUserId(userId),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🚫 Empty data check
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No money record found.'));
          }

          // ✅ Snapshot data list
          final moneyDocs = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 User Info Card
              Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text('👤 Name: $name',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('🆔 User ID: $userId',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],),

                      const SizedBox(height: 8),
                      Center(
                        child: Text('📧 Email: $email',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 🔹 Money List
              Expanded(
                child: ListView.builder(
                  itemCount: moneyDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                    moneyDocs[index].data() as Map<String, dynamic>;
                     final moneyDocId = moneyDocs[index].id;
                    final amount = data['amount'] ?? 0;
                    final dateTime = (data['date&time'] as Timestamp).toDate();
                    final formattedDate =
                    DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text('MoneyID: $moneyDocId',style: const TextStyle(
                                                          fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.blue),
                                onPressed: () async {
                                  await Clipboard.setData(ClipboardData(text: moneyDocId)); // ✅ Copy to clipboard
                                  ScaffoldMessenger.of(context).showSnackBar(
                                     SnackBar(content: Text('Copied: $moneyDocId')),
                                  );
                                },
                              ),
                            ],
                          ),
                          ListTile(
                            leading: const Icon(Icons.monetization_on_outlined),
                            title: Text(
                              '৳ $amount',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(formattedDate),
                          ),

                        ],
                      ),
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
}
