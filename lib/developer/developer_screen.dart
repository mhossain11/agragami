import 'package:flutter/material.dart';
import '../res/apptextstyle.dart';
import 'developerinfo.dart'; // <-- তোমার ফাইলের নাম অনুযায়ী import করবে

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Developer Info!',
              style: AppTextStyles.heading1,
            ),
            SizedBox(height: 20),
            DeveloperInfo(), // 👈 এখানে widget টা দেখাবে
          ],
        ),
      ),
    );
  }
}
