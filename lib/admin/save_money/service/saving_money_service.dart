import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/cachehelper/chechehelper.dart';
import '../model/usermodel.dart';

class SavingMoneyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  /// 🔍 Search user by user_id and return UserModel or null
  Future<  UserModel?> searchUserById(String userId) async {
    final result = await searchUserWithDocId(userId);
    return result?.user;
  }

  /// Search user by user_id and also return its Firestore document id
  /// and document reference (callers reuse it — no second query).
  /// The doc id is still cached under 'userDocId' (other screens read it).
  Future<
      ({
        UserModel user,
        String userDocId,
        DocumentReference<Map<String, dynamic>> userRef,
      })?> searchUserWithDocId(
    String userId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final String userDocId = doc.id;
        await CacheHelper().setString('userDocId', userDocId);

        return (
          user: UserModel.fromJson(doc.data()),
          userDocId: userDocId,
          userRef: doc.reference,
        );
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
    required DocumentReference<Map<String, dynamic>> userRef,
    required String userId,
    required String userName,
    required double amount,
    required String paymentMethod,
    required DateTime datetime,
    required String receivedBy,
    required DateTime createTime,
    required String totalAmount,
  }) async {
    try {
      // The caller already resolved the actual user document — reuse ITS
      // reference (no extra query, never a hard-coded id).

      // Step 2: Money subcollection এ add কর

      // ==========================================
      // MONEY COLLECTION
      // ==========================================

      final moneyCollection = userRef.collection('Money');

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
        // Dynamic owner — always taken from the ACTUAL user document the
        // caller resolved (`userDoc.reference`): reference + member code
        // + display name. The monthly report reads these straight from
        // the Money doc (zero extra user reads). NEVER hard-code an id.
        'user': userRef,
        'user_id': userId,
        'user_name': userName,
        'amount': amount,
        'payment_method': paymentMethod,
        'date&time': datetime,
        'create_time': Timestamp.fromDate(createTime),
        'received_by': receivedBy,

        // ⭐ Current month's total
        'total_amount': monthlyTotal,
      });

      await userRef.update({
        'payment_status.$paymentMonth': true,
        'total_amount': monthlyTotal,
      });

      await CacheHelper().setString('moneyDocID', moneyDoc.id);
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