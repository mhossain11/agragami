import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/services/firestore_service.dart';



class AuthRemoteDataSource {

  final FirebaseAuthService authService;
  final FirestoreService firestore;

  AuthRemoteDataSource({
    required this.authService,
    required this.firestore,
  });

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return authService.login(
      email: email,
      password: password,
    );
  }

  Future<QuerySnapshot<Map<String,dynamic>>> findUserByUserId(
      String userId,
      ) {

    return firestore.users
        .where(
      'user_id',
      isEqualTo: userId,
    )
        .limit(1)
        .get();
  }

  Future<DocumentSnapshot<Map<String,dynamic>>>
  getUserByUid(
      String uid,
      ) {

    return firestore.users
        .doc(uid)
        .get();
  }

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return authService.register(
      email: email,
      password: password,
    );
  }

  Future<void> createUser({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return firestore.users
        .doc(uid)
        .set(data);
  }


  // Check User Already Exists
  Future<Map<String, dynamic>?> checkUserRole(
      String inputUserId,
      ) async {
    try {
      final userSnapshot = await firestore.users
          .where(
        'user_id',
        isEqualTo: inputUserId.trim(),
      )
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final doc = userSnapshot.docs.first.data();

        return {
          'user_id': inputUserId,
          'exists': true,
          'role': doc['role'],
          'userDocId': userSnapshot.docs.first.id,
        };
      }

      return {
        'exists': false,
        'role': null,
      };
    } catch (e) {
      return null;
    }
  }

  // Find Role From Auth Collection
  Future<Map<String, dynamic>?> checkUserAdminRole(
      String inputUserId,
      ) async {
    try {
      final authSnapshot =
      await firestore.auth.get();

      for (final authDoc in authSnapshot.docs) {
        final docId = authDoc.id;

        final adminSnapshot = await firestore.auth
            .doc(docId)
            .collection('admin')
            .where(
          'user_id',
          isEqualTo: inputUserId.trim(),
        )
            .limit(1)
            .get();

        if (adminSnapshot.docs.isNotEmpty) {
          return {
            'role': 'admin',
            'authDocId': docId,
            'userDocId': adminSnapshot.docs.first.id,
          };
        }

        final userSnapshot = await firestore.auth
            .doc(docId)
            .collection('user')
            .where(
          'user_id',
          isEqualTo: inputUserId.trim(),
        )
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          return {
            'role': 'user',
            'authDocId': docId,
            'userDocId': userSnapshot.docs.first.id,
          };
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user : done
  Future<void> addUserDoneField(
      String userId,
      ) async {
    try {
      final authSnapshot =
      await firestore.auth.get();

      for (final authDoc in authSnapshot.docs) {

        final adminSnapshot =
        await firestore.auth
            .doc(authDoc.id)
            .collection('admin')
            .where(
          'user_id',
          isEqualTo: userId,
        )
            .limit(1)
            .get();

        if (adminSnapshot.docs.isNotEmpty) {
          await adminSnapshot.docs.first.reference
              .update({
            'user': 'done',
          });
          return;
        }

        final userSnapshot =
        await firestore.auth
            .doc(authDoc.id)
            .collection('user')
            .where(
          'user_id',
          isEqualTo: userId,
        )
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          await userSnapshot.docs.first.reference
              .update({
            'user': 'done',
          });
          return;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      await ref.putFile(imageFile);

      return await ref.getDownloadURL();

    } catch (e) {
      rethrow;
    }
  }



}