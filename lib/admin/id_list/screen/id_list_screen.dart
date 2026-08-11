import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../cachehelper/toast.dart';
import '../../../res/apptextstyle.dart';
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
      appBar: AppBar(title: const Text("List of user id"),centerTitle: true,),
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
          final admins = users.where((user) {
            return (user['user_id'] ?? '')
                .toString()
                .startsWith('AG2026A');
          }).toList();

          final normalUsers = users.where((user) {
            return (user['user_id'] ?? '')
                .toString()
                .startsWith('AG2026U');
          }).toList();

          admins.sort((a, b) =>
              a['user_id'].toString().compareTo(
                b['user_id'].toString(),
              ));

          normalUsers.sort((a, b) =>
              a['user_id'].toString().compareTo(
                b['user_id'].toString(),
              ));

          if (users.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          return ListView(
            children: [

              // Admin Section
              if (admins.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.green.shade100,
                  child: Center(
                    child: Text(
                      'ADMIN LIST (${admins.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              ...admins.map((user) => _buildUserCard(context, user)),

              // User Section
              if (normalUsers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  color: Colors.red.shade100,
                  child: Center(
                    child: Text(
                      'USER LIST (${normalUsers.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              ...normalUsers.map((user) => _buildUserCard(context, user)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserCard(
      BuildContext context,
      Map<String, dynamic> user,
      ) {
    final isAdmin = (user['user_id'] ?? '')
        .toString()
        .startsWith('AG2026A');

    return Card(
      color: isAdmin
          ? Colors.green.shade50
          : Colors.red.shade50,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Id record: ${user['docId']}',
                  style: AppTextStyles.style12_bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.copy,
                  color: Colors.blue,
                ),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: user['docId'],
                    ),
                  );

                  CustomToast().showToast(
                    context,
                    'Copied: ${user['docId']}',
                    Colors.green,
                  );
                },
              ),
            ],
          ),
          ListTile(
            leading: Icon(
              isAdmin
                  ? Icons.admin_panel_settings
                  : Icons.person,
              color: isAdmin
                  ? Colors.red
                  : Colors.green,
            ),
            title: Text(
              'User: ${user['user']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    'User ID: ${user['user_id']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: user['user_id'].toString(),
                      ),
                    );

                    CustomToast().showToast(
                      context,
                      'Copied: ${user['user_id']}',
                      Colors.green,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
