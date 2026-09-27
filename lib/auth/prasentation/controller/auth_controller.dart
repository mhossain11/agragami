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

class AuthController extends GetxController with WidgetsBindingObserver {

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
    WidgetsBinding.instance.addObserver(this); // 👈 register observer
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

      TextInput.finishAutofillContext();

      if (result == null) {
        Get.snackbar(
          'Login Failed',
          'Something went wrong',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

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


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('App Lifecycle => $state');

    if (state == AppLifecycleState.paused) {
      // App গেছে background এ
      _autoLogoutOnBackground();
    }
  }

  Future<void> _autoLogoutOnBackground() async {
    // শুধু login থাকা অবস্থায় logout করবো
    final isLoggedIn = CacheHelper().getLoggedIn();
    if (!isLoggedIn) return;

    await repository.logout();
    await CacheHelper().clearSession();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    emailController.dispose();
    passwordController.dispose();

    super.onClose();
  }

}