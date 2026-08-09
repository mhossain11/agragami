import 'package:Agragami/auth/screen/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../admin/home/screen/adminhome_screen.dart';
import '../../cachehelper/chechehelper.dart';
import '../../forgot_password/screen/forgotpassword_screen.dart';
import '../../user/home/screen/home_screen.dart';
import '../service/auth_service.dart';
import '../widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
 final AuthService _authService = AuthService();
  bool isLoggedIn = false;

@override
  void initState(){
    super.initState();
    _loadUserId();
    }

  void _loadUserId() {
    final savedUserId = CacheHelper().getString('userId');
    print("Loaded User ID => $savedUserId");

    if (savedUserId != null && savedUserId.isNotEmpty) {
      emailController.text = savedUserId;
    }
  }
  void login()async{
    // ✅ Form validation
    if (!_formKey.currentState!.validate()) {
      // যদি validation fail হয়, তাহলে ফাংশন থেমে যাবে
      return null;
    }
    setState(() {
      isLoading = true;
    });

    String? result = await _authService.Login(
      email: emailController.text,
      password: passwordController.text,
    );
    TextInput.finishAutofillContext();
      setState(() {
        isLoading = false;
      });

    if(result == "admin"){
      await CacheHelper().setLoggedIn(true); // ✅ Save login state
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context)=>AdminHomeScreen()));
    }else if(result == "user"){
      await CacheHelper().setLoggedIn(true); // ✅ Save login state
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context)=>HomeScreen()));
    }else{
       /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
              content: Text('Login Failed $result')));*/

      // Show toast after a short delay to make sure the widget tree is ready
       showToast(context,'Login Failed $result');
    }

  }

  void showToast(BuildContext context,String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
      
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(padding: EdgeInsets.all(10.r),
              child: Column(
                children: [
                  Padding(
                    padding:  EdgeInsets.only(top: 10.0.r,left: 8.r,right: 8.r),
                    child: Image.asset('assets/images/image_b.png',
                      fit: BoxFit.fitHeight,height: 200.h,width: 200.w,),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Create an',style: TextStyle(color: Colors.green,
                            fontSize: 25.sp,fontWeight: FontWeight.w200),),
                        Text(' account',style: TextStyle(color: Colors.red,
                            fontSize: 25.sp,fontWeight: FontWeight.w200),),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h,),
                  Center(child: CustomTextField(
                    controller: emailController,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter Email or User ID';
                      }

                      // Email হলে Email validation
                      if (value.contains('@')) {
                        final emailRegex =
                        RegExp(r'^[^@]+@[^@]+\.[^@]+$');

                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Enter a valid email';
                        }
                      }

                      // User ID হলে validation
                      else {
                        final userIdRegex =
                        RegExp(r'^AG\d{4}U\d{3}$');

                        if (!userIdRegex.hasMatch(value.trim())) {
                          return 'Enter a valid User ID';
                        }
                      }

                      return null;
                    },labelText: 'Email',)),
                  SizedBox(height: 10.h,),
                  Center(child: CustomTextFieldPassword(
                    controller: passwordController,
                    autofillHints: const [AutofillHints.password],
                    validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }

                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }

                    // ✅ Strong password regex (optional)
                   /* final strongRegex = RegExp(
                        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
                    if (!strongRegex.hasMatch(value)) {
                      return 'Include upper, lower, number & special character';
                    }*/

                    return null; // ✅ valid
                  },labelText: 'Password',)),
                  SizedBox(height: 10.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h,),
                  isLoading? Center(child: CircularProgressIndicator(),):
                  Center(
                    child: SizedBox(
                      width: 150.w,
                      child: SizedBox(
                        width: 150.w,
                        child: ElevatedButton(
                            onPressed:login,
                            child: Text('Login')),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Don\'t have an account?',style: TextStyle(
                          fontSize: 18.sp,color: Colors.grey),),
                      TextButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context)=>RegisterScreen()),);
                      }, child: Text('Sign Up',style: TextStyle(color: Colors.blue,
                          fontSize: 18.sp,letterSpacing: -1))
                      ),
                    ],
                  )
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
