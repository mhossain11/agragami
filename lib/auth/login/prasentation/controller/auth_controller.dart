import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../admin/home/screen/adminhome_screen.dart';
import '../../../../core/cachehelper/chechehelper.dart';
import '../../../../user/home/presentation/screen/home_screen.dart';
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

  // =========================
  // Register Controllers
  // =========================

  final userIdController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final birthdateController = TextEditingController();
  final nidController = TextEditingController();
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
  }

  // =========================
  // Load Saved User ID
  // =========================

  void loadUserId() {

    final savedUserId = CacheHelper().getString('userId');

    debugPrint(
      'Loaded User ID => $savedUserId',
    );

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

      if (result == 'admin') {

        await CacheHelper()
            .setLoggedIn(true);

        Get.offAll(
              () => const AdminHomeScreen(),
        );

      } else if (result == 'user') {

        await CacheHelper()
            .setLoggedIn(true);

        Get.offAll(
              () => const HomeScreen(),
        );

      } else {

        Get.snackbar(
          'Login Failed',
          result ?? 'Something went wrong',
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
        'Something went wrong',
        snackPosition:
        SnackPosition.BOTTOM,
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
        role: selectedRole.value,
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        birthdate: birthdateController.text.trim(),
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
  void onClose() {
    emailController.dispose();
    passwordController.dispose();

    userIdController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    birthdateController.dispose();
    nidController.dispose();
    nomineeNameController.dispose();
    nomineeRelationController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }
  void clearRegisterForm() {
    userIdController.clear();
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    birthdateController.clear();
    nidController.clear();
    nomineeNameController.clear();
    nomineeRelationController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    profileImage.value = null;

    showForm.value = false;
    selectedRole.value = 'user';
  }
}