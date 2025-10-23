import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../cachehelper/chechehelper.dart'; // তোমার CacheHelper path

class LogScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LogScreen({super.key});

  Future<String?> getUserDocId() async {
    return await CacheHelper().getString('userDocId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Logs'),
      ),
      body: Scaffold(
        body: SafeArea(
          child: FutureBuilder<String?>(
            future: getUserDocId(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
          
              final userDocId = snapshot.data;
              if (userDocId == null) {
                return const Center(child: Text("User not found"));
              }
          
              // 🔹 StreamBuilder for Real-time Log List
              return StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(userDocId)
                    .collection('Log')
                    .orderBy('datetime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
          
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
          
                  final logs = snapshot.data?.docs ?? [];
          
                  if (logs.isEmpty) {
                    return const Center(child: Text('No Logs Found'));
                  }
          
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final logId = log.id;
                      final name = log['name'] ?? '';
                      final email = log['email'] ?? '';
                      final userid = log['user_id'] ?? '';
                      final oldData = log['oldData'] ?? '';
                      final newData = log['newData'] ?? '';
                      final message = log['note'] ?? '';
                      final datetime = (log['datetime'] as Timestamp).toDate();
          
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          //name
                          title: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(email),
                              Text(userid),
                              const SizedBox(height: 4),
                              Text('Old: $oldData'),
                              Text('New: $newData'),
                              Text('message: $message',style: TextStyle(color: Colors.red),),
                              const SizedBox(height: 6),
                              Text(
                                'Time: ${datetime.toString()}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              await _firestore
                                  .collection('users')
                                  .doc(userDocId)
                                  .collection('Log')
                                  .doc(logId)
                                  .delete();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
