import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../service/id_list_service.dart';


class IdListScreen extends StatefulWidget {
  const IdListScreen({super.key});

  @override
  State<IdListScreen> createState() => _IdListScreenState();
}

class _IdListScreenState extends State<IdListScreen> {
  final IdListService idListService = IdListService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User List")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: idListService.getUserList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final users = snapshot.data ?? [];
          print("Users from stream: $users"); // debug

          if (users.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

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
                          child: Text('Id record: ${user['docId']}',style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.blue),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: user['docId'])); // ✅ Copy to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied: ${user['docId']}')),
                            );
                          },
                        ),
                      ],
                    ),
                    ListTile(
                      leading: const Icon(Icons.insert_drive_file_outlined),
                      title: Text(
                        'User: ${user['user']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('User ID: ${user['user_id']}'),
                    ),

                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
