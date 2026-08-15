import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const HomeCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        child: SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 50,
              ),
              const SizedBox(height: 10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}