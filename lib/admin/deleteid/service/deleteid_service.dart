import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteIdService{

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String authId = 'HUbPbYgwEss4dIE4Uiv8';

  // 🔹 Delete Admin/User
  Future<void> deleteUser({
    required String docId,
  }) async {
    await _firestore
        .collection('auth')
        .doc(authId)
        .collection('user')
        .doc(docId.trim())
        .delete();
  }



  Future<void> deleteUserByAuthDoc({ required String authDocId,
    required String userDocId}) async {
    try {
      // 1️⃣ Get user_id from the auth subcollection
      DocumentSnapshot authUserDoc = await _firestore
          .collection('auth')
          .doc(authDocId)
          .collection('user')
          .doc(userDocId)
          .get();

      if (!authUserDoc.exists) {
        print("No user found in auth/$authDocId/user/$userDocId");
        return;
      }

      String userId = authUserDoc.get('user_id');

      // 2️⃣ Delete the user document inside auth subcollection
      await _firestore
          .collection('auth')
          .doc(authDocId)
          .collection('user')
          .doc(userDocId)
          .delete();
      print("Deleted auth user document: $userDocId");

      // 3️⃣ Delete the user document in top-level 'users' collection
      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .where('user_id', isEqualTo: userId)
          .get();

      for (var doc in usersSnapshot.docs) {
        await _firestore.collection('users').doc(doc.id).delete();
        print("Deleted top-level user document: ${doc.id}");
      }

      print("All deletions completed for user_id: $userId");
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

}