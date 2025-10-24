
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import '../widgets/text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
  String selectedRole ='user';
  bool isLoading = false;
  bool showForm = false;
  bool buttonShow = true;
  String? foundRole;
    final AuthService _authService = AuthService();


  Future<String?> _signUp() async {
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
        user_id: useridController.text,
      );
      setState(() {
        isLoading = false;
      });
      if(result == 'success' ){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup Successful!')),
        );
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_)=>LoginScreen()));
      }else if(result != null && result.contains('email')){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
      else{
        //error
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Signup Failed $result')));
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Register',style: TextStyle(
                  fontSize: 40,fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              CustomTextField(controller: useridController,
                readOnly: buttonShow == false?true:false,
                labelText: 'User_ID',),
              SizedBox(height: 10,),

              isLoading? Center(child: CircularProgressIndicator(),):
              buttonShow ? SizedBox(
                width: 250,
                child: ElevatedButton(
                    onPressed:() async{
                      final userId = useridController.text.trim();

                      if (userId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter a User ID')),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      final result = await _authService.checkUserRole(userId);
                      setState((){
                        isLoading = false;
                        foundRole = result?['role'];
                        selectedRole = result?['role'] ?? 'user';
                      } );

                      if (result != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ ID found! Role: ${result['role']}')),
                        );
                        // এখানে চাইলে নিচের form visible করতে পারো
                        setState(() {
                          buttonShow = false;
                          showForm = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('❌ User ID not found')),
                        );
                        setState(() {
                          buttonShow = true;
                        });
                      }
                    },
                    child: Text('Find Id')),
              ):SizedBox(),

              foundRole== 'user'?  Visibility(
                visible: showForm,
                child: SizedBox(
                  child: Column(
                    children: [
                      CustomTextField(controller: nameController,labelText: 'Name',),
                      SizedBox(height: 10,),
                      CustomTextField(controller: emailController,labelText: 'Email',),
                      SizedBox(height: 10,),
                      CustomTextField(controller: phoneController,keyboardType: TextInputType.number,labelText: 'Phone number',),
                      SizedBox(height: 10,),
                      CustomTextField(controller: nomineeNameController,labelText: 'Nominee Name',),
                      SizedBox(height: 10,),
                      CustomTextField(controller: birthdateController,keyboardType: TextInputType.datetime,labelText: 'Birthdate',),
                      SizedBox(height: 10,),
                      CustomTextField(controller: nidController,keyboardType: TextInputType.number,labelText: 'Nid number',),
                      SizedBox(height: 10,),
                      CustomTextField(controller: addressController,maxLine: 2,labelText: 'Address',),
                      SizedBox(height: 10,),
                      CustomTextFieldPassword(controller: passwordController,keyboardType: TextInputType.number,labelText: 'Password',),
                      SizedBox(height: 10,),
                      CustomTextFieldPassword(controller: confirmPasswordController,keyboardType: TextInputType.number,labelText: 'ConfirmPassword',),
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
              ):SizedBox(),
              foundRole== 'admin'? Visibility(
                visible: showForm,
                child: SizedBox(
                  child: Column(
                    children: [
                      CustomTextField(controller: nameController,labelText: 'Name',),
                      SizedBox(height: 10,),
                      CustomTextField(controller: emailController,labelText: 'Email',),
                      SizedBox(height: 10,),
                      CustomTextField(controller: phoneController,keyboardType: TextInputType.number,labelText: 'Phone number',),
                      SizedBox(height: 10,),


                      CustomTextFieldPassword(controller: passwordController,keyboardType: TextInputType.number,labelText: 'Password',),
                      SizedBox(height: 10,),
                      CustomTextFieldPassword(controller: confirmPasswordController,keyboardType: TextInputType.number,labelText: 'ConfirmPassword',),
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

            ],
          ),
        ),
      )
    );
  }
}
