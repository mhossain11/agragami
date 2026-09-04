

import 'dart:ui';

class HomeCardData {
  final String title;
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  HomeCardData(
      {required this.title,
        required this.imagePath,
        required this.color,
        required this.onTap});
}
