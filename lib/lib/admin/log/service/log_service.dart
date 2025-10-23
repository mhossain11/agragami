
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cachehelper/chechehelper.dart';

class LogService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalLogCount() async {
    try {
      final String? userDocId = await CacheHelper().getString('userDocId');

      final snapshot = await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('Log')
          .get();

      final count = snapshot.docs.length;

      print('Total Logs: $count');
      return count;
    } catch (e) {
      print('Error getting log count: $e');
      rethrow;
    }
  }


  Future<void> addLog({
    required String name,
    required String email,
    required String userid,
    required String oldData,
    required String newData,
    required String note,

  }) async {
    try {
      final String? userDocId = await CacheHelper().getString('userDocId');

      // Step 2: Money subcollection এ add করা
      final docRef= await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('Log')

          .add({
        'name': name,
        'email': email,
        'user_id': userid,
        'oldData': oldData,
        'newData': newData,
        'notification': note,
        'datetime': Timestamp.now(),
      });
      await CacheHelper().setString('moneyDocRef', docRef.id);
      print('Money added successfully!');
    } catch (e) {
      print('Error adding money: $e');
      rethrow; // চাইলে UI তেও catch করা যায়
    }
  }


  Future<void> deleteLog(String logId) async {
    try {
      final String? userDocId = await CacheHelper().getString('userDocId');

      await _firestore
          .collection('users')
          .doc(userDocId)
          .collection('Log')
          .doc(logId)
          .delete();

      print('Log deleted successfully!');
    } catch (e) {
      print('Error deleting log: $e');
      rethrow;
    }
  }


}