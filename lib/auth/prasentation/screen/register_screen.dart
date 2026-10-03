import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/text_field.dart';
import '../controller/auth_register_controller.dart';
import '../widgets/appValidators.dart';
import '../widgets/image_picker.dart';

/// UI only — no Firebase here. Every state change is isolated in its own
/// Obx so one small change never rebuilds the whole form:
///
/// * Obx 1 -> the ID field's `enabled` flag (showForm)
/// * Obx 2 -> the Find ID button slot (showForm) + its inner spinner Obx
/// * Obx 3 -> the registration form section (showForm)
/// * Obx 4 -> the full-screen loading overlay (isLoading)
/// * inner Obx in [_imagePicker] -> only the avatar (profileImage)
///
/// The text fields themselves are plain widgets - they need no Obx.
class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  /// Repeated pattern for every plain text field on this screen:
  /// label + outlined border + validation while typing.
  TextFormField _field({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  /// Its own Obx: the loading spinner must not rebuild the whole form.
  Widget _findIdButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.searchUserId,
        child: Obx(() => controller.isLoadingId.value
            ? const CircularProgressIndicator()
            : const Text("Find ID")),
      ),
    );
  }

  /// Its own Obx: picking an image rebuilds only the avatar.
  Widget _imagePicker() {
    return Center(
      child: Obx(() => ProfileImagePicker(
            image: controller.profileImage.value,
            onTap: controller.pickProfileImage,
          )),
    );
  }

  /// Everything below the ID field once Find ID succeeded. Extracted so
  /// its Obx rebuilds this section ONLY when showForm flips - never when
  /// a spinner or the avatar changes.
  Widget _registrationForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Image
        _imagePicker(),

        SizedBox(height: 20.h),

        _field(
          controller: controller.nameController,
          label: "Name",
          validator: (value) => AppValidators.requiredField(value, 'Name'),
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.emailController,
          label: "Email",
          validator: AppValidators.email,
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.motherNameController,
          label: "Mother Name",
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.fatherNameController,
          label: "Father Name",
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.phoneController,
          label: "Phone",
          keyboardType: TextInputType.phone,
          validator: AppValidators.phone,
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.birthdateController,
          label: "Birth Date",
          keyboardType: TextInputType.datetime,
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.nidController,
          label: "NID",
          validator: AppValidators.nid,
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.addressController,
          label: "Address",
          maxLines: 2,
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.bloodController,
          label: "Blood Group",
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.nomineeNameController,
          label: "Nominee Name",
          validator: AppValidators.nominee,
        ),

        SizedBox(height: 10.h),

        _field(
          controller: controller.nomineeRelationController,
          label: "Nominee Relation",
          validator: AppValidators.nomineeRelation,
        ),

        SizedBox(height: 10.h),

        CustomTextFieldPassword(
          controller: controller.passwordController,
          validator: AppValidators.password,
          labelText: 'Password',
        ),

        SizedBox(height: 10.h),

        CustomTextFieldPassword(
          controller: controller.confirmPasswordController,
          validator: (value) => AppValidators.confirmPassword(
              value, controller.passwordController.text),
          labelText: 'ConfirmPassword',
        ),

        SizedBox(height: 20.h),

        SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: controller.register,
            child: const Text("Sign Up"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Form(
              key: controller.registerFormKey,
              child: Column(
                children: [
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Obx 1: ID field - sirf `enabled` toggle rebuild karta hai.
                  Obx(
                    () => _field(
                      controller: controller.userIdController,
                      label: "ID",
                      enabled: !controller.showForm.value,
                      validator: AppValidators.userId,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Obx 2: Find ID button slot - form khulte hi gayab.
                  Obx(
                    () => controller.showForm.value
                        ? const SizedBox.shrink()
                        : _findIdButton(),
                  ),

                  SizedBox(height: 20.h),

                  // Obx 3: registration form - sirf showForm flip par rebuild.
                  Obx(
                    () => controller.showForm.value
                        ? _registrationForm()
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // Obx 4: loading overlay - sirf isLoading par rebuild. ModalBarrier
          // saari taps/scroll absorb karta hai: loading ke dauran form par
          // kuch bhi interact nahi ho sakta (duplicate register impossible).
          Obx(
            () => controller.isLoading.value
                ? const Stack(
                    children: [
                      ModalBarrier(dismissible: false, color: Colors.black54),
                      Center(child: CircularProgressIndicator()),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
