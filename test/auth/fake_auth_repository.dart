import 'dart:io';

import 'package:Agragami/auth/domain/model/register_model.dart';
import 'package:Agragami/auth/domain/repository/auth_repository.dart';
import 'package:Agragami/auth/domain/repository/loginResult.dart';

/// In-memory [AuthRepository] used by tests so that no Firebase call is made.
class FakeAuthRepository implements AuthRepository {
  // ---------- login ----------
  int loginCallCount = 0;
  String? lastLoginEmail;
  String? lastLoginPassword;
  LoginResult? loginResult;
  Object? loginError;

  // ---------- check user id ----------
  final List<String> checkedUserIds = [];
  Map<String, dynamic>? checkUserIdResult;

  // ---------- register ----------
  final List<RegisterRequest> registeredRequests = [];
  String registerResult = 'success';
  Object? registerError;

  // ---------- image ----------
  File? imageToPick;

  // ---------- logout ----------
  int logoutCallCount = 0;

  @override
  Future<LoginResult?> login({
    required String email,
    required String password,
  }) async {
    loginCallCount++;
    lastLoginEmail = email;
    lastLoginPassword = password;

    if (loginError != null) {
      throw loginError!;
    }

    return loginResult;
  }

  @override
  Future<Map<String, dynamic>?> checkUserId(String userId) async {
    checkedUserIds.add(userId);
    return checkUserIdResult;
  }

  @override
  Future<String> register(RegisterRequest request) async {
    registeredRequests.add(request);

    if (registerError != null) {
      throw registerError!;
    }

    return registerResult;
  }

  @override
  Future<File?> pickImage() async => imageToPick;

  @override
  Future<String?> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async =>
      'https://example.com/$userId.jpg';

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }
}
