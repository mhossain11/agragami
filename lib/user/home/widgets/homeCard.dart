import 'package:flutter/material.dart';

import '../domain/models/homeCardData.dart';

class HomeCard extends StatelessWidget {
  final HomeCardData data;

  const HomeCard(this.data);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Card(
        elevation: 5,
        child: Container(
          height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(data.imagePath, color: data.color, width: 80, height: 50),
              ),
              const SizedBox(height: 5),
              Center(
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}