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

  /// Finds the auth-registry entry for [userId] in `auth/{authId}/admin|user`
  /// and returns it together with its role (admin is searched first).
  ///
  /// COLLECTION-GROUP queries replace the old walk that first downloaded the
  /// WHOLE `auth` collection and then ran 2 queries per auth doc, serially
  /// (1 + 2*A requests per lookup). Now: at most 2 requests, each `limit(1)`
  /// - only these tiny registry entries are read. Single equality filter ->
  /// the automatic collection-group single-field index is enough; no
  /// composite index needed. Errors PROPAGATE (a failed lookup must never
  /// be read as "not found").
  Future<
      ({
        QueryDocumentSnapshot<Map<String, dynamic>> doc,
        String role,
        String authDocId,
        String userDocId,
      })?> _findAuthRegistryEntry(String userId) async {

    for (final role in const ['admin', 'user']) {
      final snapshot = await firestore.firestore
          .collectionGroup(role)
          .where(
        'user_id',
        isEqualTo: userId,
      )
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;

        // Path: auth/{authDocId}/{role}/{entryId}
        final segments = doc.reference.path.split('/');

        return (
          doc: doc,
          role: role,
          authDocId: segments.length >= 2 ? segments[1] : '',
          userDocId: doc.id,
        );
      }
    }

    return null;
  }

  // Check User Already Exists
  //
  // NOTE: pehle yahan `catch { return null; }` tha - ek failed query ko
  // "user exists nahi" padha jaata tha aur registration waise bhi chalu
  // rehti thi. Ab error propagate hoti hai (controller snackbar dikhata hai).
  Future<Map<String, dynamic>?> checkUserRole(
      String inputUserId,
      ) async {
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
  }

  // Find Role From Auth Collection
  //
  // null = genuinely NOT found. A lookup failure (network/permission) now
  // propagates instead of masquerading as "no such user id".
  Future<Map<String, dynamic>?> checkUserAdminRole(
      String inputUserId,
      ) async {
    final entry = await _findAuthRegistryEntry(inputUserId.trim());

    if (entry == null) {
      return null;
    }

    return {
      'role': entry.role,
      'authDocId': entry.authDocId,
      'userDocId': entry.userDocId,
    };
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