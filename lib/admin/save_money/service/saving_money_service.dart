import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/cachehelper/chechehelper.dart';
import '../model/usermodel.dart';

class SavingMoneyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  /// 🔍 Search user by user_id and return UserModel or null
  Future<  UserModel?> searchUserById(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        String userDocId = snapshot.docs.first.id;
        await CacheHelper().setString('userDocId', userDocId);

        return UserModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print("❌ Error searching user: $e");
      rethrow;
    }
  }

  // userId দিয়ে Money add করার method
  Future<void> addMoney({
    required String userId,
    required double amount,
    required String paymentMethod,
    required DateTime datetime,
    required String receivedBy,
    required DateTime createTime,
    required String totalAmount,
  }) async {
    try {
      final String? userDocId = CacheHelper().getString('userDocId');

      if (userDocId == null || userDocId.isEmpty) {
        throw Exception('User document ID not found');
      }

      // Step 2: Money subcollection এ add কর

      final docRef = _firestore
          .collection('users')
          .doc(userDocId);


      // ==========================================
      // MONEY COLLECTION
      // ==========================================

      final moneyCollection = docRef.collection('Money');

      // ==========================================
      // CURRENT MONTH
      // ==========================================

      final paymentMonth =
          '${datetime.year}-'
          '${datetime.month.toString().padLeft(2, '0')}';

      final DateTime startOfMonth = DateTime(
        createTime.year,
        createTime.month,
        1,
      );

      final DateTime startOfNextMonth = DateTime(
        createTime.year,
        createTime.month + 1,
        1,
      );

      final snapshot = await moneyCollection
          .where(
        'date&time',
        isGreaterThanOrEqualTo:
        Timestamp.fromDate(startOfMonth),
      )
          .where(
        'date&time',
        isLessThan:
        Timestamp.fromDate(startOfNextMonth),
      ).get();

      // Current month's total
      double monthlyTotal = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final value = data['amount'];

        if (value is num) {
          monthlyTotal += value.toDouble();
        } else if (value is String) {
          monthlyTotal += double.tryParse(value) ?? 0;
        }
      }

      monthlyTotal += amount;

      final moneyDoc = await moneyCollection.add({
        'amount': amount,
        'payment_method': paymentMethod,
        'date&time': datetime,
        'create_time': Timestamp.fromDate(createTime),
        'received_by': receivedBy,

        // ⭐ Current month's total
        'total_amount': monthlyTotal,
      });

      await docRef.update({
        'payment_status.$paymentMonth': true,
        'total_amount': monthlyTotal,
      });

      await CacheHelper().setString('moneyDocID', moneyCollection.id);
      print('MoneyDocId:${moneyCollection.id}');
      print('Payment Status Updated: '
            '$paymentMonth = true',);
      print('Money added successfully!');
    } catch (e) {
      print('Error adding money: $e');
      rethrow; // চাইলে UI তেও catch করা যায়
    }
  }


}