import 'package:Agragami/cachehelper/toast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../service/user_notification_service.dart';

class UserNotificationScreen extends StatefulWidget {
  final List<String> adminDocIds;

  const UserNotificationScreen({super.key, required this.adminDocIds});

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  final UserNotificationService _notificationService = UserNotificationService();

  Future<Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>> _fetchAllNotifications() async {
    Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>> allData = {};
    for (String adminId in widget.adminDocIds) {
      final notifications = await _notificationService.getNotificationsOnce(adminId);
      allData[adminId] = notifications;
    }
    return allData;
  }

  Future<void> _markAsSeen(String adminId, String docId) async {
    await _notificationService.markAsSeen(adminId, docId);
    setState(() {}); // refresh
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.red),
      body: FutureBuilder<Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>>(
        future: _fetchAllNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No notifications yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          final allNotifications = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              children: allNotifications.entries.expand<Widget>((entry) {
                final adminId = entry.key;
                final notifications = entry.value;

                if (notifications.isEmpty) return <Widget>[];

                return <Widget>[
                  /*Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Admin: $adminId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),*/
                  ...notifications.map<Widget>((doc) {
                    final data = doc.data();
                    final title = data['title'] ?? '';
                    final message = data['message'] ?? '';
                    final time = (data['datetime'] as Timestamp).toDate();
                    final seen = data['seen'] ?? false;

                    return InkWell(
                      onTap: () async {
                        if (!seen) await _markAsSeen(adminId, doc.id);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(title),
                            content: SingleChildScrollView(child: Text(message)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                            ],
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(Icons.notifications_active, color: seen ? Colors.grey : Colors.blue),
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
                              Text('${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ];
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
