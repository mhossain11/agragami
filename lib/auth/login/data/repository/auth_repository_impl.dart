
import 'dart:io';

import 'package:Agragami/auth/login/domain/model/register_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/CacheService.dart';
import '../../domain/repository/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final CacheService cacheService;

  AuthRepositoryImpl({
    required this.remote,
    required this.cacheService,
  });
  final ImagePicker _picker = ImagePicker();
  @override
  Future<String?> login({
    required String email,
    required String password,
  }) async {

    String loginEmail = email.trim();

    // User ID দিয়ে Login
    if (!loginEmail.contains('@')) {
      final snapshot =
      await remote.findUserByUserId(
        loginEmail,
      );

      if (snapshot.docs.isEmpty) {
        return 'User ID not found';
      }

      loginEmail =
      snapshot.docs.first['email'];
    }

    // Firebase Auth Login
    final credential = await remote.login(email: loginEmail, password: password,);

    // Firestore User Data
    final userDoc =
    await remote.getUserByUid(
      credential.user!.uid,
    );

    if (!userDoc.exists) {
      return 'User data not found';
    }

    final data = userDoc.data()!;

    // Cache Save
    await cacheService.saveUserData(
      data,
      userDoc.id,
    );

    return data['role'];
  }

  @override
  Future<Map<String, dynamic>?> checkUserId(
      String userId,
      ) async {

    return await remote.checkUserAdminRole(
      userId,
    );
  }

  @override
  Future<String> register(
      RegisterRequest request,
      ) async {

    final duplicate = await remote.checkUserRole(
      request.userId,
    );

    if (duplicate?['exists'] == true) {
      return "User ID already exists";
    }

    // Firebase Auth
    final credential = await remote.register(email: request.email, password: request.password,);

    final uid =
        credential.user!.uid;

    // Upload Image
    final imageUrl =
    await remote.uploadProfileImage(
      imageFile: request.profileImage,
      userId: request.userId,
    );

    // Save Firestore
    await remote.createUser(
      uid: uid,
      data: {
        'uid': uid,
        'name': request.name,
        'email': request.email,
        'role': request.role,
        'user_id': request.userId,
        'phone': request.phone,
        'address': request.address,
        'birthdate': request.birthdate,
        'nid': request.nid,
        'nomineeName': request.nomineeName,
        'nomineeRelation': request.nomineeRelation,
        'profileImage': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
      },
    );
    await remote.addUserDoneField(
      request.userId,
    );

    return "success";
  }
  @override
  Future<File?> pickImage() async {

    final XFile? file =
    await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (file == null) {
      return null;
    }

    return File(file.path);
  }
  
  @override
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) {
    return remote.uploadProfileImage(
      imageFile: imageFile,
      userId: userId,
    );
  }

  @override
  Future<void> logout() async {

   // await cacheService.clear();

    await remote.authService.logout();
  }
}