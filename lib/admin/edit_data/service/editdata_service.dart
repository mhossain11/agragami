import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/cachehelper/chechehelper.dart';

/*
class EditDataService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> editMoney({
    required String userId,
    required double newAmount,
    required String paymentMethod,
    required String receivedBy,
    required DateTime dateTime,
  }) async {
    // Find user
    final snapshot = await _firestore
        .collection('users')
        .where(
      'user_id',
      isEqualTo: userId,
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    final userDocId =
        snapshot.docs.first.id;

    // Money document ID
    final moneyDocId =
    CacheHelper().getString(
      'moneyDocID',
    );

    if (moneyDocId == null ||
        moneyDocId.isEmpty) {
      throw Exception(
        'Money document ID not found',
      );
    }

    // Update Money
    await _firestore
        .collection('users')
        .doc(userDocId)
        .collection('Money')
        .doc(moneyDocId)
        .update({
      'amount': newAmount,
      'payment_method': paymentMethod,
      'received_by': receivedBy,
      'date&time':
      Timestamp.fromDate(dateTime),

      // Monthly report যদি create_time দিয়ে
      // না চলে তাহলে এটা রাখার দরকার নেই।
      //
      // যদি date অনুযায়ী month change করতে চাও:
      'create_time':
      Timestamp.fromDate(dateTime),
    });
  }
}*/
class EditDataService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> editMoney({
    required String userId,
    required String moneyDocId,
    required double newAmount,
    required String paymentMethod,
    required String receivedBy,
    required DateTime dateTime,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .where(
      'user_id',
      isEqualTo: userId,
    )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    final userDocId = snapshot.docs.first.id;

    await _firestore
        .collection('users')
        .doc(userDocId)
        .collection('Money')
        .doc(moneyDocId)
        .update({
      'amount': newAmount,
      'payment_method': paymentMethod,
      'received_by': receivedBy,
      'date&time': Timestamp.fromDate(dateTime),
    });
  }
}
