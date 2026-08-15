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
    required String datetime,
  }) async {
    try {
      final String? userDocId = await CacheHelper().getString('userDocId');

      // Step 2: Money subcollection এ add করা
      final docRef= await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('Money')
          .add({
        'amount': amount,
        'payment_method': paymentMethod,
        'date&time': datetime,
      });
      await CacheHelper().setString('moneyDocID', docRef.id);
      print('MoneyDocId:${docRef.id}');
      print('Money added successfully!');
    } catch (e) {
      print('Error adding money: $e');
      rethrow; // চাইলে UI তেও catch করা যায়
    }
  }


}