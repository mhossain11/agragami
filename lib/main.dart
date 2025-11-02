import 'package:Agragami/user/home/screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'admin/home/screen/adminhome_screen.dart';
import 'auth/screen/login_screen.dart';
import 'cachehelper/chechehelper.dart';
import 'cachehelper/theme.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await CacheHelper.init();
  runApp(ScreenUtilInit(
    designSize: Size(360, 690),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context,child)=>const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _checkLogin() async {
    final isLoggedIn =await CacheHelper().getLoggedIn();
    final role = await CacheHelper().getString('isRole');

    if (isLoggedIn) {
      if (role == "admin") {
        return const AdminHomeScreen();
      } else if(role == "user") {
        return const HomeScreen();
      }else{
        return const LoginScreen();
      }
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeData().somitiTheme,
      home: FutureBuilder(
          future: _checkLogin(),
          builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
           Center(child: CircularProgressIndicator(),);
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        }else if(snapshot.hasData){
          return snapshot.data!;
        }else{
          return const LoginScreen();
        }

          }),
    );
  }

}


