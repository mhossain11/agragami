
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../cachehelper/chechehelper.dart';

class EditDataService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ✅ Edit Money document
  Future<void> editMoney({
    required String userId,
    required double newAmount,
  }) async {
    // UserDocId বের করা
    final snapshot = await _firestore
        .collection('users')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) throw Exception('User not found');

    final userDocId = snapshot.docs.first.id;

   final moneyDocId= await CacheHelper().getString('moneyDocID');
   print('moneyDocID2: $moneyDocId');

    // Update Money document
    await _firestore
        .collection('users')
        .doc(userDocId)
        .collection('Money')
        .doc(moneyDocId)
        .update({
      'amount': newAmount,
      'date&time': Timestamp.now(), // optional: নতুন update time
    });
  }
}