import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/text_field.dart';
import '../controller/auth_controller.dart';
import '../widgets/appValidators.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
            () => Stack(
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

                    /// User ID
                    TextFormField(
                      controller: controller.userIdController,
                      enabled: !controller.showForm.value,
                      decoration: const InputDecoration(
                        labelText: "User ID",
                        border: OutlineInputBorder(),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => AppValidators.userId(value),



                    ),

                    SizedBox(height: 10.h),

                    if (!controller.showForm.value)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.searchUserId,
                          child: controller.isLoadingId.value
                              ? const CircularProgressIndicator()
                              : const Text("Find ID"),
                        ),
                      ),

                    SizedBox(height: 20.h),

                    if (controller.showForm.value) ...[

                      /// Image
                      Center(
                        child: GestureDetector(
                          onTap: controller.pickProfileImage,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: controller.profileImage.value != null
                                  ? FileImage(controller.profileImage.value!)
                                  : null,
                              child: controller.profileImage.value == null
                                  ? const Icon(
                                Icons.camera_alt,
                                size: 35,
                                color: Colors.green,
                              )
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      TextFormField(
                        controller: controller.nameController,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value)=> AppValidators.requiredField(
                          value,
                          'Name',),
                      ),

                      SizedBox(height: 10.h),

                      TextFormField(
                        controller: controller.emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value)=> AppValidators.email(value),

                      ),

                      SizedBox(height: 10.h),

                      TextFormField(
                        controller: controller.phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Phone",
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value)=> AppValidators.phone(value),

                      ),

                      SizedBox(height: 10.h),

                      TextFormField(
                        controller: controller.birthdateController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: "Birth Date",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      TextFormField(
                        controller: controller.nidController,
                        decoration: const InputDecoration(
                          labelText: "NID",
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value)=> AppValidators.Nid(value),
                      ),

                      SizedBox(height: 10.h),

                      TextFormField(
                        controller: controller.addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 10.h),

                      TextFormField(
                        controller: controller.nomineeNameController,
                        decoration: const InputDecoration(
                          labelText: "Nominee Name",
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value)=> AppValidators.nominee(value),
                      ),

                      SizedBox(height: 10.h),

                      TextFormField(
                        controller: controller.nomineeRelationController,
                        decoration: const InputDecoration(
                          labelText: "Nominee Relation",
                          border: OutlineInputBorder(),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value)=> AppValidators.nomineeRelation(value),
                      ),

                      SizedBox(height: 10.h),

                      CustomTextFieldPassword(
                        controller: controller.passwordController,
                        validator: (value)=> AppValidators.password(value),
                        labelText: 'Password',
                      ),

                      SizedBox(height: 10.h),

                      CustomTextFieldPassword(
                        controller: controller.confirmPasswordController,
                        validator: (value)=> AppValidators.confirmPassword(
                            value,controller.passwordController.text),
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
                    ]
                  ],
                ),
              ),
            ),

            if (controller.isLoading.value)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
