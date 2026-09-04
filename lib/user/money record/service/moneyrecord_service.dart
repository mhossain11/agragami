/*

import 'package:cloud_firestore/cloud_firestore.dart';

class MoneyRecordService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMoneyListByUserId(String userDocId) {


    // 🔹 Step 2: ওই user এর Money collection return করো
     return _firestore
        .collection('users')
        .doc(userDocId)
        .collection('Money')
        .orderBy('date&time', descending: true)
        .snapshots();
  }

}*/
