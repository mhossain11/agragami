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
      String userId ) {

    return firestore.users
        .where(
      'user_id', isEqualTo: userId,)
        .limit(1)
        .get();
  }

  Future<DocumentSnapshot<Map<String,dynamic>>> getUserByUid(
      String uid,) {

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

  // =========================
  // Registration rollback
  // =========================

  Future<void> deleteCurrentUser() {
    return authService.deleteCurrentUser();
  }

  Future<void> deleteUserDocument({
    required String uid,
  }) {
    return firestore.users
        .doc(uid)
        .delete();
  }


  // =========================
  // Shared auth-registry lookup
  // =========================

  /// Walks `auth/{authId}/admin|user` looking for [userId] and returns the
  /// first match together with its role - the role search and the "done"
  /// update both use this exact traversal (admin before user, per auth doc).
  Future<
      ({
        QueryDocumentSnapshot<Map<String, dynamic>> doc,
        String role,
        String authDocId,
        String userDocId,
      })?> _findAuthRegistryEntry(String userId) async {

    final authSnapshot = await firestore.auth.get();

    for (final authDoc in authSnapshot.docs) {
      for (final role in const ['admin', 'user']) {

        final roleSnapshot = await firestore.auth
            .doc(authDoc.id)
            .collection(role)
            .where(
          'user_id',
          isEqualTo: userId,
        )
            .limit(1)
            .get();

        if (roleSnapshot.docs.isNotEmpty) {
          final doc = roleSnapshot.docs.first;
          return (
            doc: doc,
            role: role,
            authDocId: authDoc.id,
            userDocId: doc.id,
          );
        }
      }
    }

    return null;
  }

  // Check User Already Exists
  Future<Map<String, dynamic>?> checkUserRole(
      String inputUserId,
      ) async {
    try {
      final userSnapshot = await findUserByUserId(inputUserId.trim());

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
      final entry = await _findAuthRegistryEntry(inputUserId.trim());

      if (entry == null) {
        return null;
      }

      return {
        'role': entry.role,
        'authDocId': entry.authDocId,
        'userDocId': entry.userDocId,
      };
    } catch (e) {
      return null;
    }
  }

  // Update user : done
  Future<void> addUserDoneField(
      String userId,
      ) async {
    final entry = await _findAuthRegistryEntry(userId);

    if (entry != null) {
      await entry.doc.reference.update({
        'user': 'done',
      });
    }
  }

  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('$userId.jpg');

    await ref.putFile(imageFile);

    return await ref.getDownloadURL();
  }
}