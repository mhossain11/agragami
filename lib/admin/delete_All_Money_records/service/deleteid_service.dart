import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteIdService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> deleteAllMoney({
    required String userId,
  }) async {
    try {
      final userSnap = await _firestore
          .collection('users')
          .where(
        'user_id',
        isEqualTo: userId.trim(),
      )
          .limit(1)
          .get();

      if (userSnap.docs.isEmpty) {
        throw Exception('User ID পাওয়া যায়নি।');
      }

      final userRef = userSnap.docs.first.reference;

      // User-এর সব Money record
      final moneySnap = await userRef
          .collection('Money')
          .get();

      // সব Money delete
      for (final moneyDoc in moneySnap.docs) {
        await moneyDoc.reference.delete();
      }

      print(
        '✅ ${moneySnap.docs.length}টি Money record delete হয়েছে',
      );
    } catch (e) {
      print('❌ Money Delete Error: $e');
      rethrow;
    }
  }
}