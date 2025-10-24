import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyDeleteService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 User এর Money রেকর্ড মুছে ফেলা
  Future<void> deleteMoneyByUserId({
    required String userId,
    required String moneyDocId,
  }) async {
    // প্রথমে user document বের করো
    final userSnapshot = await _firestore
        .collection('users')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    final userDocId = userSnapshot.docs.first.id;

    // এখন ওই Money ডকুমেন্টটা delete করো
    await _firestore
        .collection('users')
        .doc(userDocId)
        .collection('Money')
        .doc(moneyDocId)
        .delete();
  }
}