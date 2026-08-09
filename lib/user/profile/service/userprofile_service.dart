import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/userprofile_model.dart';

class UserProfileService {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserProfileModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfileModel.fromFirestore(doc);
    } else {
      return null;
    }
  }


  Future<void> updateUser(
      String uid,
      Map<String, dynamic> data,
      ) async {
    try {
      data['updated_at'] =
          FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(uid)
          .update(data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> uploadProfileImage(
      String uid,
      File imageFile,
      ) async {
    try {
      final fileName =
          DateTime.now().millisecondsSinceEpoch;

      final ref = _storage
          .ref()
          .child('profile_images')
          .child(uid)
          .child('$fileName.jpg');

      final uploadTask =
      await ref.putFile(imageFile);

      final imageUrl =
      await uploadTask.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String> updateProfileImage(
      String uid,
      File imageFile,
      ) async {
    try {
      final imageUrl =
      await uploadProfileImage(
        uid,
        imageFile,
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .update({
        'profileImage': imageUrl,
        'updated_at':
        FieldValue.serverTimestamp(),
      });

      return imageUrl;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Delete Profile Image
  Future<void> deleteProfilePhoto(
      String userId,
      ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'photo': '',
        'updated_at':
        FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
        'Failed to delete photo: $e',
      );
    }
  }

}
