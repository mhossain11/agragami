
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/cachehelper/chechehelper.dart';
import '../../../core/cachehelper/toast.dart';
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
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final LogService _logService = LogService();
  String name='';
  String DocId='';
  String email='';
  String adminId='';
  bool _isUpdating = false;

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
  Future<void> _showEditDialog(
      String notificationId,
      String oldTitle,
      String oldMessage,
      ) async {
    titleController.text = oldTitle;
    messageController.text = oldMessage;

    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            AlertDialog(
              title: const Text('Edit Notification'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    await _noteService.updateNotification(
                      adminDocId: widget.adminDocId,
                      notificationId: notificationId,
                      title: titleController.text.trim(),
                      message: messageController.text.trim(),
                    );

                    await _logService.addLog(
                      name: name,
                      email: email,
                      userid: adminId,
                      oldData: oldTitle,
                      newData: titleController.text.trim(),
                      note: 'Notification Updated',
                    );

                    Navigator.pop(context);

                    CustomToast().showToast(
                      context,
                      'Notification Updated',
                      Colors.green,
                    );
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
            if (_isUpdating)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    messageController.dispose();
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // Edit Button
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                            size: 20,
                          ),
                          onPressed: () {
                            _showEditDialog(
                              doc.id,
                              title,
                              message,
                            );
                          },
                        ),

                        // Delete Button
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () =>
                              _confirmDelete(context, doc.id),
                        ),
                      ],
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
