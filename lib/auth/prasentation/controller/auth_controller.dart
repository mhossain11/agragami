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

  // =========================
  // Register Controllers
  // =========================

  final userIdController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final birthdateController = TextEditingController();
  final nidController = TextEditingController();
  final bloodController = TextEditingController();
  final nomineeNameController = TextEditingController();
  final nomineeRelationController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // =========================
  // Forms
  // =========================

  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();

  // =========================
  // State
  // =========================

  final isLoading = false.obs;
  final isLoadingId = false.obs;
  final showForm = false.obs;

  final selectedRole = 'user'.obs;

  Rx<File?> profileImage = Rx<File?>(null);


  // =========================
  // Lifecycle
  // =========================

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

  // =========================
  // Check User ID
  // =========================

  Future<void> searchUserId() async {
    if (userIdController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter User ID",
      );
      return;
    }

    try {
      isLoadingId.value = true;

      final result = await repository.checkUserId(
        userIdController.text.trim(),
      );

      if (result != null) {
        selectedRole.value =
            result['role'] ?? 'user';

        showForm.value = true;

        if(emailController.text.isNotEmpty) {
          emailController.clear();
        }
      } else {
        Get.snackbar(
          "Failed",
          "User ID not found",
        );
      }
    } finally {
      isLoadingId.value = false;
    }
  }

  // =========================
  // Pick Image
  // =========================

  Future<void> pickProfileImage() async {
    final image = await repository.pickImage();

    if (image != null) {
      profileImage.value = image;
    }
  }

  // =========================
  // Register
  // =========================

  Future<void> register() async {
    if (!registerFormKey.currentState!.validate()) {
      return;
    }

    if (profileImage.value == null) {
      Get.snackbar(
        'Image Required',
        'Please select a profile image',
      );
      return;
    }

    try {
      isLoading.value = true;

      final request = RegisterRequest(
        userId: userIdController.text.trim(),
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        fatherName: fatherNameController.text.trim(),
        motherName: motherNameController.text.trim(),
        role: selectedRole.value,
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        birthdate: birthdateController.text.trim(),
        blood: bloodController.text.trim(),
        nid: nidController.text.trim(),
        nomineeName: nomineeNameController.text.trim(),
        nomineeRelation: nomineeRelationController.text.trim(),
        profileImage: profileImage.value!,
      );

      final result = await repository.register(
        request,
      );

      if (result == "success") {
        Get.snackbar(
          "Success",
          "Registration Successful",
        );

        clearRegisterForm();
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          "Failed",
          result,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // Logout
  // =========================

  Future<void> logout() async {
    await repository.logout();

    await CacheHelper().clear();

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
    await CacheHelper().clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    userIdController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    birthdateController.dispose();
    nidController.dispose();
    bloodController.dispose();
    nomineeNameController.dispose();
    nomineeRelationController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }
  void clearRegisterForm() {
    userIdController.clear();
    nameController.clear();
    emailController.clear();
    fatherNameController.clear();
    motherNameController.clear();
    phoneController.clear();
    addressController.clear();
    birthdateController.clear();
    nidController.clear();
    bloodController.clear();
    nomineeNameController.clear();
    nomineeRelationController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    profileImage.value = null;

    showForm.value = false;
    selectedRole.value = 'user';
  }
}