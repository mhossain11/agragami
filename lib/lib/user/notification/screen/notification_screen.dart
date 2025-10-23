/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: _notificationService.getAllAdminNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications yet.'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data();
              final title = data['title'] ?? '';
              final message = data['message'] ?? '';
              final time = (data['datetime'] as Timestamp).toDate();

              return Card(
                elevation: 5,
                child: InkWell(
                  onTap: (){
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(title),
                          content: SingleChildScrollView(
                            child: Text(message),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ListTile(
                    leading: Icon(Icons.notifications_active, color: Colors.blue),
                    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(message,maxLines: 2,overflow: TextOverflow.ellipsis,),
                    trailing: Text(
                      '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



*/


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
      appBar: AppBar(title: Text('Notifications')),
      body: ListView(
        children: adminDocIds.map((adminId) {
          return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            stream: _notificationService.getNotifications(adminId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox.shrink();
              final notifications = snapshot.data!;
              return Column(
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

