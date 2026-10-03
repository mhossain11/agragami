import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../res/apptextstyle.dart';
import '../admin/home/controller/admin_home_controller.dart';
import 'developerinfo.dart'; // <-- তোমার ফাইলের নাম অনুযায়ী import করবে

class DeveloperScreen extends StatelessWidget {
   DeveloperScreen({super.key,required this.color});
  Color color ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: color,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              // Hidden unlock with progress messages: tap 1 and tap 2
              // show "click 1" / "click 2", the 3rd shows "delete button
              // open" and makes the button appear on Admin Home.
              // Counter + flag live in AdminHomeController - only an
              // admin session registers it, so user sessions never unlock.
              onTap: () {
                if (Get.isRegistered<AdminHomeController>()) {
                  final message =
                      Get.find<AdminHomeController>().onDeveloperSecretTap();
                  Get.snackbar(
                    'Developer',
                    message,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Text(
                'Developer Info!',
                style: AppTextStyles.heading1,
              ),
            ),
            SizedBox(height: 20),
            DeveloperInfo(color:color), // 👈 এখানে widget টা দেখাবে
          ],
        ),
      ),
    );
  }
}
