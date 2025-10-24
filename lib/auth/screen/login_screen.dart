
import 'package:agragami/auth/screen/register_screen.dart';
import 'package:flutter/material.dart';
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

    if(result == "Admin"){
      await CacheHelper().setLoggedIn(true); // ✅ Save login state
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context)=>AdminHomeScreen()));
    }else if(result == "User"){
      await CacheHelper().setLoggedIn(true); // ✅ Save login state
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context)=>HomeScreen()));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Login Failed $result')));
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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Login',style: TextStyle(
                  fontSize: 40,fontWeight: FontWeight.bold),),
              SizedBox(height: 20,),
              Center(child: CustomTextField(controller: emailController,labelText: 'Email',)),
              SizedBox(height: 10,),
              Center(child: CustomTextFieldPassword(controller: passwordController,labelText: 'Password',)),
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
    );

  }

}
