import 'package:cloud_firestore/cloud_firestore.dart';

class CreateIdService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String authId = 'HUbPbYgwEss4dIE4Uiv8';

  // 🔹 Add Admin/User
  Future<String> addUserId({
    required String role, // "admin" or "user"
    required String userId,
  }) async {
    // Create a new document reference first
    final docRef = await _firestore
        .collection('auth')
        .doc(authId)
        .collection(role)
        .add({'user_id': userId.trim()});

    // Return the generated document ID
    return docRef.id;
  }

  // 🔹 Update Admin/User
  Future<void> updateUserId({
    required String role,
    required String docId,
    required String newUserId,
  }) async {
    await _firestore
        .collection('auth')
        .doc(authId)
        .collection(role)
        .doc(docId.trim())
        .update({'user_id': newUserId.trim()});
  }


}