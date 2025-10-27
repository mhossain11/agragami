
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cachehelper/chechehelper.dart';

class NoteService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addNote({
    required String title,
    required String message,
  }) async {
    try {
      final String? userDocId = await CacheHelper().getString('userDocId');

      // Step 2: Money subcollection এ add করা
      final docRef= await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('notification')

          .add({
        'title': title,
        'message': message,
        'datetime': Timestamp.now(),
        'seen':false,
      });
      await CacheHelper().setString('moneyDocRef', docRef.id);
      print('Money added successfully!');
    } catch (e) {
      print('Error adding money: $e');
      rethrow; // চাইলে UI তেও catch করা যায়
    }
  }

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

    // Merge all streams and sum counts
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

  /// 🔹 Get first unread notification ID of an admin
  Future<String?> getFirstUnreadNotificationId(String adminDocId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(adminDocId)
        .collection('notification')
        .where('seen', isEqualTo: false)
        .orderBy('datetime', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) return snapshot.docs.first.id;
    return null;
  }



  /// 🔹 Get all notifications for an admin (for NotificationScreen)
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getNotifications(String adminDocId) {
    return _firestore
        .collection('users')
        .doc(adminDocId)
        .collection('notification')
        .orderBy('datetime', descending: true)
        .snapshots()
        .map((snap) => snap.docs);
  }

  // 🔹 Delete a single notification
  Future<void> deleteNotification(String adminDocId,String docId) async {
    await _firestore
        .collection('users')
        .doc(adminDocId)
        .collection('notification')
        .doc(docId)
        .delete();
  }

  Future<void> deleteAllNotifications(String adminDocId) async {
    final notifications = await _firestore
        .collection('users')
        .doc(adminDocId)
        .collection('notification')
        .get();

    for (var doc in notifications.docs) {
      await doc.reference.delete();
    }
  }




}