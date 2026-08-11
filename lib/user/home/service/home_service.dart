import 'package:cloud_firestore/cloud_firestore.dart';


class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Single user's total money
  Future<int> getUserTotalMoney(String userDocId) async {
    double total = 0;

    final snapshot = await _firestore
        .collection('users')
        .doc(userDocId)
        .collection('Money')
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final amount = data['amount'];

      if (amount is num) {
        total += amount.toDouble();
      } else if (amount is String) {
        total += double.tryParse(amount) ?? 0;
      }
    }

    return total.toInt();
  }

  // All users total money
  Future<int> getAllUsersTotalAmount() async {
    int total = 0;

    try {
      final usersSnapshot =
      await _firestore.collection('users').get();

      for (final userDoc in usersSnapshot.docs) {
        final moneySnapshot = await _firestore
            .collection('users')
            .doc(userDoc.id)
            .collection('Money')
            .get();

        for (final moneyDoc in moneySnapshot.docs) {
          final data = moneyDoc.data();
          final amount = data['amount'];

          if (amount is num) {
            total += amount.toInt();
          } else if (amount is String) {
            total += int.tryParse(amount) ?? 0;
          }
        }
      }

      print('🔥 ALL USERS TOTAL = $total');

      return total;
    } catch (e) {
      print('❌ Total money error: $e');
      return 0;
    }
  }
}
