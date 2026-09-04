import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../../contact/screen/contact_screen.dart';
import '../../../core/cachehelper/chechehelper.dart';
import '../../../core/routes/app_routes.dart';
import '../../../developer/developer_screen.dart';
final FirebaseAuth _auth = FirebaseAuth.instance;

void onSelected(int item, BuildContext context) async {
  switch (item) {
    case 0:
      await _auth.signOut();
      await CacheHelper().setLoggedIn(false);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          Get.offAllNamed(AppRoutes.login);
        }
      });
      break;

    case 1:
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ContactScreen(color: Colors.red,)));
      }
      break;

    case 2:
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(
            builder: (context)=>DeveloperScreen(color: Colors.red,)));
      }
      break;
  }
}