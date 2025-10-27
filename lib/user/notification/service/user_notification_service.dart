import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Get all admin doc IDs
  Future<List<String>> getAdminDocIds() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// 🔹 Get unread notification count for multiple admins
  Stream<int> getTotalUnreadCount(List<String> adminDocIds) {
    final streams = adminDocIds.map((id) {
      return _firestore
          .collection('users')
          .doc(id)
          .collection('notification')
          .where('seen', isEqualTo: false)
          .snapshots()
          .map((snap) => snap.docs.length);
    }).toList();

    return Stream<int>.multi((controller) {
      final counts = List<int>.filled(adminDocIds.length, 0);
      for (int i = 0; i < streams.length; i++) {
        streams[i].listen((count) {
          counts[i] = count;
          controller.add(counts.reduce((a, b) => a + b));
        });
      }
    });
  }

  /// 🔹 Mark notification as seen
  Future<void> markAsSeen(String adminDocId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(adminDocId)
        .collection('notification')
        .doc(notificationId)
        .update({'seen': true});
  }

  /// 🔹 Delete a notification
  Future<void> deleteNotification(String adminDocId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(adminDocId)
        .collection('notification')
        .doc(notificationId)
        .delete();
  }

  /// 🔹 Future-based fetch for all notifications of an admin
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getNotificationsOnce(String adminDocId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(adminDocId)
        .collection('notification')
        .orderBy('datetime', descending: true)
        .get();

    return snapshot.docs;
  }
}
