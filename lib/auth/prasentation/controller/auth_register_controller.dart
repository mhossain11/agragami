import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/model/register_model.dart';
import '../../domain/repository/auth_repository.dart';
import '../../../core/cachehelper/chechehelper.dart';
import 'auth_controller.dart';

class RegisterController extends GetxController {

  final AuthRepository repository;

  RegisterController(this.repository);

  // =========================
  // Controllers
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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // =========================
  // Form
  // =========================

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
  // Find User ID
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
  // Image Picker
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
        "Image Required",
        "Please select profile image",
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

      final result = await repository.register(request);

      if (result == "success") {

        // Save the fresh user id: LoginScreen's ID/Email field prefills from
        // this key (AuthController.loadUserId reads it).
        await CacheHelper().setString(
          'userId',
          request.userId,
        );

        // Get.back() PEHLE: GetX ka back() agar koi snackbar khula dekhta hai
        // toh woh use close karke return ho jaata tha - route pop hi nahi hota
        // tha aur success snackbar turant gayab ho jata tha.
        Get.back();

        // Login route neeche zinda hai - uska prefill abhi refresh kar do
        // (warna onInit ek hi baar chalta hai aur field khali dikhta).
        if (Get.isRegistered<AuthController>()) {
          Get.find<AuthController>().loadUserId();
        }

        Get.snackbar(
          "Success",
          "Registration Successful",
        );

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
  // Dispose
  // =========================

  @override
  void onClose() {

    userIdController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    birthdateController.dispose();
    nidController.dispose();
    bloodController.dispose();
    nomineeNameController.dispose();
    nomineeRelationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }
}