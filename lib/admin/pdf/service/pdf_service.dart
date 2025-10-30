import 'package:cloud_firestore/cloud_firestore.dart';

class PdfService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 Fetch user's Money subcollection ordered by date
  Future<List<Map<String, dynamic>>> fetchMoneyData(String userDocId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('Money')
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? '',
          'amount': data['amount'] ?? 0,
          'type': data['type'] ?? '', // income/expense
          'date': (data['date'] as Timestamp?)?.toDate(),
        };
      }).toList();
    } catch (e) {
      print("⚠️ Error fetching money data: $e");
      return [];
    }
  }
}