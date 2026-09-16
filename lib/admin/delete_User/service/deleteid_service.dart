/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

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



*//*


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



  Future<void> deleteUserByAuthUid({
    required String authDocId,       // auth collection-এর uid
    required String authUserDocId, // auth/{uid}/user subcollection-এর doc id
  }) async {
    try {
      // 1️⃣ Get user_id from auth subcollection
      final authUserDoc = await _firestore
          .collection('auth')
          .doc(authDocId)
          .collection('user')
          .doc(authUserDocId)
          .get();

      if (!authUserDoc.exists) {
        print("❌ No user found in auth/$authDocId/user/$authUserDocId");
        return;
      }

      final String userId = authUserDoc.get('user_id');

      // 2️⃣ Find matching user document in 'users' collection
      final userSnap = await _firestore
          .collection('users')
          .where('user_id', isEqualTo: userId)
          .get();

      if (userSnap.docs.isEmpty) {
        print("❌ No user found in users collection for user_id: $userId");
        return;
      }

      // 3️⃣ Move each found user document
      for (var doc in userSnap.docs) {
        final fromDocRef = _firestore.collection('users').doc(doc.id);
        final toDocRef = _firestore.collection('delete_users').doc(doc.id);

        final Map<String, dynamic> userData = doc.data();
        // Add deletedAt without changing other dates
        userData['deletedAt'] = FieldValue.serverTimestamp();

        // Copy main user doc
        await toDocRef.set(userData);

        // Copy 'Money' subcollection
        final moneySnap = await fromDocRef.collection('Money').get();
        for (var moneyDoc in moneySnap.docs) {
          await toDocRef.collection('Money').doc(moneyDoc.id).set(moneyDoc.data());
        }

        // Delete original 'Money' subcollection
        for (var moneyDoc in moneySnap.docs) {
          await moneyDoc.reference.delete();
        }

        // Delete original user doc
        await fromDocRef.delete();
      }

      // 4️⃣ Delete auth subcollection document
      await _firestore.collection('auth').doc(authDocId).collection('user').doc(authUserDocId).delete();

      // 5️⃣ Optionally delete auth uid doc itself (if empty or needed)
      final remaining = await _firestore.collection('auth').doc(authDocId).collection('user').get();
      if (remaining.docs.isEmpty) {
        await _firestore.collection('auth').doc(authDocId).delete();
      }

      print("✅ User moved to delete_users with Money subcollection and auth deleted");
    } catch (e) {
      print("⚠️ Error deleting user: $e");
    }
  }
}
*/


import 'package:cloud_firestore/cloud_firestore.dart';

class DeleteIdService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> deleteAllMoney({
    required String userId,
  }) async {
    try {
      final userSnap = await _firestore
          .collection('users')
          .where(
        'user_id',
        isEqualTo: userId.trim(),
      )
          .limit(1)
          .get();

      if (userSnap.docs.isEmpty) {
        throw Exception('User ID পাওয়া যায়নি।');
      }

      final userRef = userSnap.docs.first.reference;

      // User-এর সব Money record
      final moneySnap = await userRef
          .collection('Money')
          .get();

      // সব Money delete
      for (final moneyDoc in moneySnap.docs) {
        await moneyDoc.reference.delete();
      }

      print(
        '✅ ${moneySnap.docs.length}টি Money record delete হয়েছে',
      );
    } catch (e) {
      print('❌ Money Delete Error: $e');
      rethrow;
    }
  }
}