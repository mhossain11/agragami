import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../user/home/presentation/screen/home_screen.dart';
import '../../../core/cachehelper/chechehelper.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/routes/app_routes.dart';
import '../../domain/model/register_model.dart';
import '../../domain/repository/auth_repository.dart';
import '../screen/login_screen.dart';

class AuthController extends GetxController {

  final AuthRepository repository;

  AuthController(this.repository);

  // =========================
  // Login Controllers
  // =========================

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();


  final isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    loadUserId();
  }

  // =========================
  // Load Saved User ID
  // =========================

  void loadUserId() {

    final savedUserId = CacheHelper().getString('userId');

    print('Loaded User ID => $savedUserId',);

    if (savedUserId != null && savedUserId.isNotEmpty) {
      emailController.text = savedUserId;
    }
  }

  // =========================
  // Login
  // =========================

  Future<void> login() async {

    // Validation
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {

      final result =
      await repository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      //TextInput.finishAuto fillContext();

      if (result == null) {
        TextInput.finishAutofillContext();
        Get.snackbar(
          'Login Failed',
          'Something went wrong',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Successful login => mark the session as logged in, so the app can
      // restore it on the next launch (kill app -> reopen -> still logged in).
      // NOTE: do NOT set this to false here, and do not add any forced
      // logout on app background/pause - that breaks session persistence.
     // await CacheHelper().setLoggedIn(true);
      await CacheHelper().setString('userId', result.userId); // 👈 Firestore এর real user_id
      await CacheHelper().setString('isRole', result.role);

      if (result.role == 'admin') {
        Get.offAllNamed(AppRoutes.adminHome);

      } else if (result.role == 'user') {
        Get.offAllNamed(AppRoutes.home);

      } else {

        Get.snackbar(
          'Login Failed',
          'Something went wrong',
          snackPosition:
          SnackPosition.BOTTOM,
        );
      }

    } catch (e) {

      debugPrint(
        'Login Error => $e',
      );

      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );

    } finally {

      isLoading.value = false;
    }
  }


  Future<void> logout() async {
    await repository.logout();

    await CacheHelper().clearSession();

    Get.offAllNamed('/login');
  }


  // NOTE: Session must survive app background/kill — no forced auto-logout
  // on lifecycle events. Logout happens only via the explicit logout action.

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    super.onClose();
  }

}