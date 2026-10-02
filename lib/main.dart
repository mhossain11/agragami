 import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'core/cachehelper/chechehelper.dart';
import 'core/cachehelper/theme.dart';
import 'core/routes/app_pages.dart';
import 'core/services/CacheService.dart';
import 'core/session/session_guard.dart';

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

  // Launch-time session validation. This runs only on a cold start (fresh
  // process) — never on background/foreground — so:
  //   * backgrounding the app never logs the user out;
  //   * process death (swipe-away from Recent Apps, OOM kill, crash,
  //     reboot) invalidates the previous session -> next route is Login.
  // (Android has no reliable "app was destroyed" callback; see SessionGuard.)
  await SessionGuard.invalidatePreviousSession();

  runApp(ScreenUtilInit(
    designSize: Size(360, 690),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context,child)=>const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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


