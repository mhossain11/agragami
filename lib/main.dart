import 'package:Agragami/user/home/presentation/screen/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'admin/home/screen/adminhome_screen.dart';
import 'auth/login/prasentation/screen/login_screen.dart';
import 'core/cachehelper/chechehelper.dart';
import 'core/cachehelper/theme.dart';
import 'core/routes/app_pages.dart';
import 'core/services/CacheService.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();
  await CacheHelper.init();
  // Register CacheService
  await Get.putAsync<CacheService>(() => CacheService().init(),);

  runApp(ScreenUtilInit(
    designSize: Size(360, 690),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context,child)=>const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   /*_checkLogin() {
    final isLoggedIn =CacheHelper().getLoggedIn();
    final role = CacheHelper().getString('isRole');

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
  }*/
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeData().somitiTheme,
      initialRoute: AppPages.getInitialRoute(),
      getPages: AppPages.pages,
      //home:_checkLogin(),
    );
  }

}


