import 'package:flutter/material.dart';
import '../res/apptextstyle.dart';
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
            Text(
              'Developer Info!',
              style: AppTextStyles.heading1,
            ),
            SizedBox(height: 20),
            DeveloperInfo(color:color), // 👈 এখানে widget টা দেখাবে
          ],
        ),
      ),
    );
  }
}
