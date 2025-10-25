import 'package:flutter/material.dart';
import '../service/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatelessWidget {
  final List<String> adminDocIds;
  final NotificationService _notificationService = NotificationService();

  NotificationScreen({super.key, required this.adminDocIds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications'),backgroundColor: Colors.red,),
      body: ListView(
        children: adminDocIds.map((adminId) {
          return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            stream: _notificationService.getNotifications(adminId),
            builder: (context, snapshot) {
            //  if (!snapshot.hasData) return SizedBox.shrink();
            // 🌀 Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              // 🚫 No data state
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return  Center(child: Text('No notifications yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)));
              }

              final notifications = snapshot.data!;
              return Column (
                children: notifications.map((doc) {
                  final data = doc.data();
                  final title = data['title'] ?? '';
                  final message = data['message'] ?? '';
                  final time = (data['datetime'] as Timestamp).toDate();
                  final seen = data['seen'] ?? false;

                  return Card(
                    elevation: 5,
                    child: InkWell(
                      onTap: () async {
                        if (!seen) {
                          await _notificationService.markAsSeen(adminId, doc.id);
                        }
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(title),
                            content: SingleChildScrollView(child: Text(message)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Icon(Icons.notifications_active,
                            color: seen ? Colors.grey : Colors.blue),
                        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: Text(
                          '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2,'0')}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }).toList(),

              );
            },
          );
        }).toList(),
      ),
    );
  }
}

