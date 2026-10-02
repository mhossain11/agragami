import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../user/home/presentation/screen/home_screen.dart';
import '../../../core/cachehelper/chechehelper.dart';
import '../../../core/routes/app_routes.dart';
import '../../domain/model/register_model.dart';
import '../../domain/repository/auth_repository.dart';
import '../screen/login_screen.dart';

class AuthController extends GetxController{

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

      // Save this run's session: userId (prefills the login form), role
      // (bookkeeping) and the logged-in flag.
      // NOTE: backgrounding the app (home button / other app) must never
      // clear this or call logout — the session stays valid while the
      // process is alive. The next COLD START (kill / swipe-away) lands on
      // the Login screen anyway (SessionGuard + AppPages.getInitialRoute).
      await CacheHelper().setLoggedIn(true);
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


  // NOTE: No logout on lifecycle events (paused / inactive / hidden /
  // resumed / detached). Backgrounding keeps the session; only the explicit
  // logout action ends it. A new process (kill / swipe-away from Recents)
  // is handled at launch by SessionGuard + AppPages.getInitialRoute.


  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    super.onClose();
  }

}