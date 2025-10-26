
import 'package:agragami/auth/screen/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../admin/home/screen/adminhome_screen.dart';
import '../../cachehelper/chechehelper.dart';
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
    CacheHelper.init();
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
              child: Padding(padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0,left: 8,right: 8),
                    child: Image.asset('assets/images/image_b.png',
                      fit: BoxFit.fitHeight,height: 180,width: 200,),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Create an',style: TextStyle(color: Colors.green,
                            fontSize: 25,fontWeight: FontWeight.w200),),
                        Text(' account',style: TextStyle(color: Colors.red,
                            fontSize: 25,fontWeight: FontWeight.w200),),
                      ],
                    ),
                  ),
                  SizedBox(height: 20,),
                  Center(child: CustomTextField(controller: emailController,validator: (value){
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

                  },labelText: 'Email',)),
                  SizedBox(height: 10,),
                  Center(child: CustomTextFieldPassword(controller: passwordController,validator: (value){
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
                  SizedBox(height: 10,),
                  isLoading? Center(child: CircularProgressIndicator(),):
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                          onPressed:login,
                          child: Text('Login')),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Don\'t have an account?',style: TextStyle(
                          fontSize: 18,color: Colors.grey),),
                      TextButton(onPressed: (){
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                                builder: (context)=>RegisterScreen()),(route)=>false);
                      }, child: Text('Sign Up',style: TextStyle(color: Colors.blue,
                          fontSize: 18,letterSpacing: -1))
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
