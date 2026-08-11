
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../cachehelper/toast.dart';
import '../service/auth_service.dart';
import '../widgets/text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController useridController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController nidController = TextEditingController();
  TextEditingController nomineeNameController = TextEditingController();
  TextEditingController nomineeRelationController = TextEditingController();
  String selectedRole ='user';
  bool isLoading = false;
  bool isLoadingId = false;
  bool showForm = false;
  bool buttonShow = true;
  File? profileImageFile;
  String? profileImageUrl;
  String? uploadedImageUrl;
  final ImagePicker _imagePicker = ImagePicker();
  String? foundRole;
    final AuthService _authService = AuthService();

  Future<void> pickProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 65,
        maxWidth: 600,
        maxHeight: 600,
      );

      if (pickedFile == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        profileImageFile = File(pickedFile.path);
      });
    } catch (e) {
      debugPrint('Image Pick Error: $e');

      if (!mounted) return;

      CustomToast().showToast(
        context,
        'Unable to select image',
        Colors.red,
      );
    }
  }

  void searchId() async{
    final userId = useridController.text.trim();

    // 🔹 প্রথমে user_id duplicate কিনা চেক করো
    setState(() => isLoadingId = true);
    final roleCheck = await _authService.checkUserRole(userId);

    if (roleCheck != null && roleCheck['user_id'] == userId) {
      // যদি user_id আগে থেকেই থাকে, error return করো
      setState(() => isLoadingId = false);
      CustomToast().showToast(context,'This ${roleCheck['user_id']} already exists',Colors.red);
      return;
    }

    if (userId.isEmpty) {
      /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a User ID')),);*/
      CustomToast(). showToast(context,'Please enter a User ID',Colors.red);
      setState(() => isLoadingId = false);
      return;
    }
    setState(() => isLoadingId = true);
    final result = await _authService.checkUserAdminRole(userId);
    setState((){
      isLoadingId = false;
      foundRole = result?['role'];
      selectedRole = result?['role'] ?? 'user';
    } );

    if (result != null) {
      CustomToast().showToast(context,'ID found! Role: ${result['role']}',Colors.green);

      setState(() {
        buttonShow = false;
        showForm = true;
      });
    } else {
      /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ User ID not found')),
        );*/
      CustomToast().showToast(context,'User ID not found',Colors.red);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (profileImageFile == null) {
      CustomToast().showToast(
        context,
        'Please select a profile image',
        Colors.red,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final userId = useridController.text.trim();

      // 1️⃣ Upload image first
      final imageUrl = await _authService.uploadProfileImage(
        imageFile: profileImageFile!,
        userId: userId,
      );

      if (imageUrl == null || imageUrl.isEmpty) {
        CustomToast().showToast(
          context,
          'Image upload failed',
          Colors.red,
        );
        return;
      }

      print("Image URL => $imageUrl");

      // 2️⃣ Create user with image URL
      final result = await _authService.signup(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: selectedRole,
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        birthdate: birthdateController.text.trim(),
        nid: nidController.text.trim(),
        nomineeName: nomineeNameController.text.trim(),
        nomineeRelation: nomineeRelationController.text.trim(),
        user_id: userId,
        profileImage: imageUrl,
      );

      if (result != 'success') {
        CustomToast().showToast(
          context,
          'Signup Failed: $result',
          Colors.red,
        );
        return;
      }

      // 3️⃣ Update auth collection
      await _authService.addUserDoneFieldById(userId);

      if (!mounted) return;

      CustomToast().showToast(
        context,
        'Signup Successful!',
        Colors.green,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } catch (e) {
      debugPrint("Signup Error => $e");

      CustomToast().showToast(
        context,
        'Registration failed',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }







  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    useridController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    birthdateController.dispose();
    nidController.dispose();
    nomineeNameController.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding:  EdgeInsets.all(8.0.r),
                child: Column(
                  children: [
                    Text('Register',style: TextStyle(
                        fontSize: 40.sp,fontWeight: FontWeight.bold),),
                    SizedBox(height: 20.h,),
                    CustomTextField(controller: useridController,
                     // readOnly: buttonShow == false?true:false,
                      enabled:  buttonShow,
                      labelText: 'User_ID',),
                    SizedBox(height: 10.h,),

                    isLoadingId? Center(child: CircularProgressIndicator(),):
                    buttonShow ? SizedBox(
                      width: 250.w,
                      child: ElevatedButton(
                          onPressed:searchId,
                          child: Text('Find Id')),):
                    SizedBox(),

                    Visibility(
                      visible: showForm,
                      child: SizedBox(
                        child: Column(
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: pickProfileImage,
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
                                    backgroundImage: profileImageFile != null
                                        ? FileImage(profileImageFile!)
                                        : null,
                                    child: profileImageUrl == null
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

                            const SizedBox(height: 8),

                            Text(
                              'Add Profile Photo',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            SizedBox(height: 15.h),
                            CustomTextField(controller: nameController,labelText: 'Name',isRequired: true,
                                validator: (value){
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Name is required';
                                  }
                                  return null; // valid
                                }
                            ),
                            SizedBox(height: 10.h,),
                            CustomTextField(controller: emailController,isRequired: true,
                              validator: (value){
                              if(value!.isEmpty){
                                return 'Please enter an email';
                              }
                              if(!value.contains('@')){
                                return 'Please enter a valid email';
                              }
                              if(!value.contains('.')){
                                return 'Please enter a valid email';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Enter a valid email address';
                              }
                              return null;

                            },labelText: 'Email',),
                            SizedBox(height: 10.h,),
                            CustomTextField(controller: phoneController,
                              validator: (value){
                                if (value == null || value.trim().isEmpty) return 'Phone is required';
                                final pattern = RegExp(r'^(?:\+?88)?01[3-9]\d{8}$');
                                return pattern.hasMatch(value.trim()) ? null : 'Enter valid Bangladesh phone';
                              },keyboardType: TextInputType.number,labelText: 'Phone number',),
                            SizedBox(height: 10.h,),
                            CustomTextField(controller: birthdateController,keyboardType: TextInputType.datetime,labelText: 'Birthdate',),
                            SizedBox(height: 10.h,),
                            CustomTextField(controller: nidController,isRequired: true,
                              validator: (value){
                              if (value == null || value.trim().isEmpty) {
                                return 'NID is required';
                              }

                              // Must be digits only and length between 10 and 17
                              final pattern = RegExp(r'^[0-9]{10,17}$');

                              if (!pattern.hasMatch(value.trim())) {
                                return 'NID must be 10–17 digits long';
                              }

                              return null; // valid
                            },keyboardType: TextInputType.number,labelText: 'Nid number',),
                            SizedBox(height: 10.h,),
                            CustomTextField(controller: addressController,maxLine: 2,labelText: 'Address',),
                            SizedBox(height: 10.h,),
                            CustomTextField(controller: nomineeNameController,
                              labelText: 'Nominee Name',isRequired: true,
                                validator: (value){
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nominee Name is required';
                                  }
                                  return null; // valid
                                }
                            ),
                            SizedBox(height: 10.h,),
                            CustomTextField(controller: nomineeRelationController,
                              labelText: 'Nominee Relation',isRequired: true,
                                validator: (value){
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nominee Relation is required';
                                  }
                                  return null; // valid
                                }
                            ),
                            SizedBox(height: 10.h,),
                            CustomTextFieldPassword(controller: passwordController,
                              validator: (value){
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }

                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }

                            /*  // ✅ Strong password regex (optional)
                              final strongRegex = RegExp(
                                  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
                              if (!strongRegex.hasMatch(value)) {
                                return 'Include upper, lower, number & special character';
                              }*/

                              return null; // ✅ valid
                            },isRequired: true,labelText: 'Password',),
                            SizedBox(height: 10.h,),
                            CustomTextFieldPassword(controller: confirmPasswordController,isRequired: true,
                              validator: (value){
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },labelText: 'ConfirmPassword',),
                            SizedBox(height: 10.h,),
                            //button
                            SizedBox(
                              width: 250.w,
                              child: ElevatedButton(
                                  onPressed: _signUp,
                                  child: Text('Sign Up')),
                            ),
                          ],
                        ),
                      ),
                    ),


                  //admin
                  /*  foundRole== 'admin'? Visibility(
                      visible: showForm,
                      child: SizedBox(
                        child: Column(
                          children: [
                            CustomTextField(controller: nameController,labelText: 'Name',),
                            SizedBox(height: 10,),
                            CustomTextField(controller: emailController,
                              validator: (value){
                                if(value!.isEmpty){
                                  return 'Please enter an email';
                                }
                                if(!value.contains('@')){
                                  return 'Please enter a valid email';
                                }
                                if(!value.contains('.')){
                                  return 'Please enter a valid email';
                                }
                                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                if (!emailRegex.hasMatch(value.trim())) {
                                  return 'Enter a valid email address';
                                }
                                return null;

                              },labelText: 'Email',),
                            SizedBox(height: 10,),
                            CustomTextField(controller: phoneController,
                              validator: (value){
                                if (value == null || value.trim().isEmpty) return 'Phone is required';
                                final pattern = RegExp(r'^(?:\+?88)?01[3-9]\d{8}$');
                                return pattern.hasMatch(value.trim()) ? null : 'Enter valid Bangladesh phone';
                              },keyboardType: TextInputType.number,labelText: 'Phone number',),
                            SizedBox(height: 10,),
                            CustomTextFieldPassword(controller: passwordController,
                              validator: (value){
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }

                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }

                                *//*  // ✅ Strong password regex (optional)
                              final strongRegex = RegExp(
                                  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
                              if (!strongRegex.hasMatch(value)) {
                                return 'Include upper, lower, number & special character';
                              }*//*

                                return null; // ✅ valid
                              },labelText: 'Password',),
                            SizedBox(height: 10,),
                            CustomTextFieldPassword(controller: confirmPasswordController,
                              validator: (value){
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },labelText: 'ConfirmPassword',),
                            SizedBox(height: 10,),
                            //button
                            isLoading? Center(child: CircularProgressIndicator(),):
                            SizedBox(
                              width: 250,
                              child: ElevatedButton(
                                  onPressed: _signUp,
                                  child: Text('Sign Up')),
                            ),
                            SizedBox(height: 20,),

                          ],
                        ),
                      ),
                    ):SizedBox(),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Already have an account?',style: TextStyle(
                            fontSize: 18,color: Colors.grey),),
                        TextButton(onPressed: (){
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                              builder: (context)=>LoginScreen()),(route)=>false);
                        }, child: Text('Sign In',style: TextStyle(color: Colors.blue,
                            fontSize: 18,letterSpacing: -1))
                        ),
                      ],
                    )
          */
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 15),
                    Text(
                      "Creating Account...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      )
    );
  }
}
