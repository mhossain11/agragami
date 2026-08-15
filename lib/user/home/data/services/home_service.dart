/*
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getAllUsersTotalAmount() async {
    int total = 0;

    final usersSnapshot =
    await _firestore.collection('users').get();

    for (final userDoc in usersSnapshot.docs) {
      final moneySnapshot = await _firestore
          .collection('users')
          .doc(userDoc.id)
          .collection('Money')
          .get();

      for (final moneyDoc in moneySnapshot.docs) {
        final amount = moneyDoc.data()['amount'];

        if (amount is num) {
          total += amount.toInt();
        }
      }
    }

    return total;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getSummary() {
    return _firestore
        .collection('summary')
        .doc('summary')
        .get();
  }
}*/
