import 'package:Agragami/cachehelper/toast.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../cachehelper/chechehelper.dart';
import '../../log/service/log_service.dart';
import '../service/note_service.dart';

class NotificationListScreen extends StatefulWidget {
  final String adminDocId;
  NotificationListScreen({super.key, required this.adminDocId});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
 // ✅ single admin ID
  final NoteService _noteService = NoteService();

  final LogService _logService = LogService();
  String name='';
  String DocId='';
  String email='';
  String adminId='';

  @override
  void initState() {
    super.initState();
    getName();
  }
  Future<String?> getName() async {
    name =  (await CacheHelper().getString('names'))!;
    DocId =  (await CacheHelper().getString('userDocId'))!;
    adminId =  (await CacheHelper().getString('adminId'))!;
    email =  (await CacheHelper().getString('email'))!;
    if (name == null || name.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }if (adminId == null ||adminId.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }

    if (DocId == null || DocId.isEmpty) {
      debugPrint('Error: UserDocId not found in cache!');
      return null;
    }
    if (email == null || email.isEmpty) {
      debugPrint('Error: Name not found in cache!');
      return null;
    }
    setState(() {
      name = name;
      DocId = DocId;
      email = email;
      adminId = adminId;
    });
  }

  Future<void> _confirmDelete(BuildContext context, String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _noteService.deleteNotification(widget.adminDocId, docId);
      await _logService.addLog(
          name:  name,
          email: email,
          userid:  adminId,
          oldData:  widget.adminDocId,
          newData: docId,
          note: 'Notification deleted'
      );
      CustomToast().showToast(context, 'Notification deleted', Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.green),
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: _noteService.getNotifications(widget.adminDocId), // ✅ single stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data();
              final title = data['title'] ?? '';
              final message = data['message'] ?? '';
              final time = (data['datetime'] as Timestamp).toDate();
              final seen = data['seen'] ?? false;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: InkWell(
                  onTap: () async {
                    if (!seen) await _noteService.markAsSeen(widget.adminDocId, doc.id);
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
                  child: ListTile(
                    leading: Icon(
                      Icons.notifications_active,
                      color: seen ? Colors.grey : Colors.blue,
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
                        Text(
                          '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _confirmDelete(context, doc.id),
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
