import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import '../../../../core/widgets/text_field.dart';
import '../../../../forgot_password/screen/forgotpassword_screen.dart';
import 'register_screen.dart';
import '../controller/auth_controller.dart';

class LoginScreen extends GetView<AuthController> {

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SingleChildScrollView(

        child: SafeArea(

          child: Form(

            key: controller.loginFormKey,

            child: SizedBox(

              height:
              MediaQuery.of(context).size.height,

              child: Padding(

                padding:
                EdgeInsets.all(10.r),

                child: Column(

                  children: [

                    // =====================
                    // Logo
                    // =====================

                    Padding(

                      padding: EdgeInsets.only(
                        top: 10.r,
                        left: 8.r,
                        right: 8.r,
                      ),

                      child: Image.asset(
                        'assets/images/image_b.png',
                        fit: BoxFit.fitHeight,
                        height: 200.h,
                        width: 200.w,
                      ),
                    ),

                    // =====================
                    // Title
                    // =====================

                    SizedBox(
                      width: double.infinity,

                      child: Row(

                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [

                          Text(
                            'Create an',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 25.sp,
                              fontWeight:
                              FontWeight.w200,
                            ),
                          ),

                          Text(
                            ' account',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 25.sp,
                              fontWeight:
                              FontWeight.w200,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // =====================
                    // Email / User ID
                    // =====================

                    CustomTextField(

                      controller:
                      controller.emailController,

                      autofillHints: const [
                        AutofillHints.email,
                      ],

                      labelText:
                      'Email or User ID',

                      validator: (value) {

                        if (value == null ||
                            value.trim().isEmpty) {

                          return
                            'Please enter Email or User ID';
                        }

                        if (value.contains('@')) {

                          final emailRegex =
                          RegExp(
                            r'^[^@]+@[^@]+\.[^@]+$',
                          );

                          if (!emailRegex.hasMatch(
                              value.trim())) {

                            return
                              'Enter a valid email';
                          }

                        } else {

                          final userIdRegex =
                          RegExp(
                            r'^AG\d{4}[UA]\d{3}$',
                          );

                          if (!userIdRegex.hasMatch(
                              value.trim())) {

                            return
                              'Enter a valid User ID';
                          }
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    // =====================
                    // Password
                    // =====================

                    CustomTextFieldPassword(

                      controller:
                      controller.passwordController,

                      autofillHints: const [
                        AutofillHints.password,
                      ],

                      labelText:
                      'Password',

                      validator: (value) {

                        if (value == null ||
                            value.isEmpty) {

                          return
                            'Password is required';
                        }

                        if (value.length < 8) {

                          return
                            'Password must be at least 8 characters';
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 10.h),

                    // =====================
                    // Forgot Password
                    // =====================

                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.end,

                      children: [

                        TextButton(

                          onPressed: () {

                            Get.to(
                                  () =>
                              const ForgotPasswordScreen(),
                            );
                          },

                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16.sp,
                              fontWeight:
                              FontWeight.w400,
                              decoration:
                              TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // =====================
                    // Login Button
                    // =====================

                    Obx(() {

                      if (controller.isLoading.value) {

                        return const Center(
                          child:
                          CircularProgressIndicator(),
                        );
                      }

                      return SizedBox(
                        width: 150.w,

                        child: ElevatedButton(

                          onPressed:
                          controller.login,

                          child:
                          const Text('Login'),
                        ),
                      );
                    }),

                    SizedBox(height: 20.h),

                    // =====================
                    // Register
                    // =====================

                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.end,

                      children: [

                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.grey,
                          ),
                        ),

                        TextButton(

                          onPressed: () {

                            Get.to(
                                  () =>
                              const RegisterScreen(),
                            );
                          },

                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18.sp,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
