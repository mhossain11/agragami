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

  /// Single source for every text controller so onClose never misses one.
  List<TextEditingController> get _textControllers => [
        userIdController,
        fatherNameController,
        motherNameController,
        nameController,
        phoneController,
        addressController,
        birthdateController,
        nidController,
        bloodController,
        nomineeNameController,
        nomineeRelationController,
        emailController,
        passwordController,
        confirmPasswordController,
      ];

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

  final Rx<File?> profileImage = Rx<File?>(null);

  // =========================
  // Find User ID
  // =========================

  Future<void> searchUserId() async {

    final userId = userIdController.text.trim();

    if (userId.isEmpty) {
      _snackbar("Error", "Please enter User ID");
      return;
    }

    try {

      isLoadingId.value = true;

      final result = await repository.checkUserId(userId);

      if (result != null) {

        selectedRole.value = result['role'] ?? 'user';

        showForm.value = true;

      } else {

        _snackbar("Failed", "User ID not found");
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
      _snackbar("Image Required", "Please select profile image");
      return;
    }

    try {

      isLoading.value = true;

      final request = _buildRegisterRequest();

      final result = await repository.register(request);

      if (result == "success") {
        await _onRegistrationSuccess(request.userId);
      } else {
        _snackbar("Failed", result);
      }

    } catch (e) {

      _snackbar("Error", e.toString());

    } finally {

      isLoading.value = false;
    }
  }

  /// Reads every field once (trimmed) for the repository.
  RegisterRequest _buildRegisterRequest() {
    return RegisterRequest(
      userId: _text(userIdController),
      name: _text(nameController),
      email: _text(emailController),
      password: _text(passwordController),
      fatherName: _text(fatherNameController),
      motherName: _text(motherNameController),
      role: selectedRole.value,
      phone: _text(phoneController),
      address: _text(addressController),
      birthdate: _text(birthdateController),
      blood: _text(bloodController),
      nid: _text(nidController),
      nomineeName: _text(nomineeNameController),
      nomineeRelation: _text(nomineeRelationController),
      profileImage: profileImage.value!,
    );
  }

  Future<void> _onRegistrationSuccess(String userId) async {

    // Save the fresh user id: LoginScreen's ID/Email field prefills from
    // this key (AuthController.loadUserId reads it).
    await CacheHelper().setString('userId', userId);

    // Get.back() PEHLE: GetX ka back() agar koi snackbar khula dekhta hai
    // toh woh use close karke return ho jaata tha - route pop hi nahi hota
    // tha aur success snackbar turant gayab ho jata tha.
    Get.back();

    // Login route neeche zinda hai - uska prefill abhi refresh kar do
    // (warna onInit ek hi baar chalta hai aur field khali dikhta).
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().loadUserId();
    }

    _snackbar("Success", "Registration Successful");
  }

  // =========================
  // Helpers
  // =========================

  /// One place for the register flow's snackbars (title + message).
  void _snackbar(String title, String message) {
    Get.snackbar(title, message);
  }

  String _text(TextEditingController controller) => controller.text.trim();

  // =========================
  // Dispose
  // =========================

  @override
  void onClose() {

    for (final controller in _textControllers) {
      controller.dispose();
    }

    super.onClose();
  }
}
