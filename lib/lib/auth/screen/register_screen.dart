
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
  TextEditingController roleController = TextEditingController();
  String selectedRole = "User";
  bool isLoading = false;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Register',style: TextStyle(
                  fontSize: 40,fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              selectedRole == "Admin" ? SizedBox():
              CustomTextField(controller: useridController,labelText: 'User_ID',),
              SizedBox(height: 10,),
              CustomTextField(controller: nameController,labelText: 'Name',),
              SizedBox(height: 10,),
              CustomTextField(controller: emailController,labelText: 'Email',),
              SizedBox(height: 10,),
              CustomTextFieldPassword(controller: passwordController,labelText: 'Password',),
              SizedBox(height: 10,),
              CustomTextFieldPassword(controller: confirmPasswordController,labelText: 'ConfirmPassword',),
              SizedBox(height: 10,),
              DropdownButtonFormField(
                initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder()
                  ),
                  items: ["User","Admin"].map((e){
                return DropdownMenuItem(
                    value: e,
                    child: Text(e));}).toList(),
                  onChanged: (String? newValue){
                          setState(() {
                            selectedRole = newValue!;
                          });
                  }),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Already have an account?',style: TextStyle(
                      fontSize: 18,color: Colors.grey),),
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
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
