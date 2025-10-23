import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserListService{
  // FireStore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Get Money List Stream by userId (user_id field থেকে)
  Stream<QuerySnapshot> getMoneyListByUserId(String userId) async* {
    // 🔹 Step 1: user document খুঁজে বের করো
    final userSnapshot = await _firestore
        .collection('users')
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (userSnapshot.docs.isEmpty) {
      // যদি না পায়, তাহলে খালি Stream দাও
      yield* const Stream.empty();
      return;
    }

    final userDocId = userSnapshot.docs.first.id;

    // 🔹 Step 2: ওই user এর Money collection return করো
    yield* _firestore
        .collection('users')
        .doc(userDocId)
        .collection('Money')
        .orderBy('date&time', descending: true)
        .snapshots();
  }

}