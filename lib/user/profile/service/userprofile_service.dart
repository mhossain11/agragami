import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/userprofile_model.dart';

class UserProfileService{
  final _firestore = FirebaseFirestore.instance;

  Future<UserProfileModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfileModel.fromFirestore(doc);
    } else {
      return null;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }
}