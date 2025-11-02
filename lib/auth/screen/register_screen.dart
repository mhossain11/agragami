
import 'package:Agragami/cachehelper/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  String? foundRole;
    final AuthService _authService = AuthService();


  Future<String?> _signUp() async {
    // ✅ Form validation
    if (!_formKey.currentState!.validate()) {
      // যদি validation fail হয়, তাহলে ফাংশন থেমে যাবে
      return null;
    }
      setState(() {
        isLoading = true;
      });
      String? result = await _authService.signup(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: selectedRole,
        phone: phoneController.text,
        address: addressController.text,
        birthdate: birthdateController.text,
        nid: nidController.text,
        nomineeName: nomineeNameController.text,
        nomineeRelation: nomineeRelationController.text,
        user_id: useridController.text,
      );
      setState(() {
        isLoading = false;
      });
      if(result == 'success' ){
        /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Successful!')),
        );*/
        CustomToast().showToast(context,'Signup Successful!',Colors.green);
       await _authService.addUserDoneFieldById(useridController.text);

        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_)=>LoginScreen()));
      }else if(result != null && result.contains('email')){
        CustomToast().showToast(context,'content: Text($result)',Colors.red);
      }
      else{
        //error
        CustomToast().showToast(context,'Signup Failed $result',Colors.red);
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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('Register',style: TextStyle(
                    fontSize: 40,fontWeight: FontWeight.bold),),
                SizedBox(height: 20,),
                CustomTextField(controller: useridController,
                 // readOnly: buttonShow == false?true:false,
                  enabled:  buttonShow,
                  labelText: 'User_ID',),
                SizedBox(height: 10,),

                isLoadingId? Center(child: CircularProgressIndicator(),):
                buttonShow ? SizedBox(
                  width: 250,
                  child: ElevatedButton(
                      onPressed:searchId,
                      child: Text('Find Id')),):
                SizedBox(),

                Visibility(
                  visible: showForm,
                  child: SizedBox(
                    child: Column(
                      children: [
                        CustomTextField(controller: nameController,labelText: 'Name',isRequired: true,
                            validator: (value){
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null; // valid
                            }
                        ),
                        SizedBox(height: 10,),
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
                        SizedBox(height: 10,),
                        CustomTextField(controller: phoneController,
                          validator: (value){
                            if (value == null || value.trim().isEmpty) return 'Phone is required';
                            final pattern = RegExp(r'^(?:\+?88)?01[3-9]\d{8}$');
                            return pattern.hasMatch(value.trim()) ? null : 'Enter valid Bangladesh phone';
                          },keyboardType: TextInputType.number,labelText: 'Phone number',),
                        SizedBox(height: 10,),
                        CustomTextField(controller: birthdateController,keyboardType: TextInputType.datetime,labelText: 'Birthdate',),
                        SizedBox(height: 10,),
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
                        SizedBox(height: 10,),
                        CustomTextField(controller: addressController,maxLine: 2,labelText: 'Address',),
                        SizedBox(height: 10,),
                        CustomTextField(controller: nomineeNameController,
                          labelText: 'Nominee Name',isRequired: true,
                            validator: (value){
                              if (value == null || value.trim().isEmpty) {
                                return 'Nominee Name is required';
                              }
                              return null; // valid
                            }
                        ),
                        SizedBox(height: 10,),
                        CustomTextField(controller: nomineeRelationController,
                          labelText: 'Nominee Relation',isRequired: true,
                            validator: (value){
                              if (value == null || value.trim().isEmpty) {
                                return 'Nominee Relation is required';
                              }
                              return null; // valid
                            }
                        ),
                        SizedBox(height: 10,),
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
                        SizedBox(height: 10,),
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
                        SizedBox(height: 10,),
                        //button
                        isLoading? Center(child: CircularProgressIndicator(),):
                        SizedBox(
                          width: 250,
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
      )
    );
  }
}
