import 'dart:io';

import '../model/register_model.dart';
import 'loginResult.dart';

abstract class AuthRepository {

  Future<LoginResult?> login({
    required String email,
    required String password,
  });

  // Register User ID Check
  Future<Map<String, dynamic>?> checkUserId(
      String userId,
      );

  // Register
  Future<String> register(
      RegisterRequest request,
      );

  // Pick Image
  Future<File?> pickImage();
  //image upload
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  });

  // Logout
  Future<void> logout();

}