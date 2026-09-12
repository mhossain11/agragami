import 'package:flutter/material.dart';

/// A single tappable dashboard tile: icon image + label.
/// Every menu entry on the admin home screen is one of these —
/// no more copy-pasted Card/Container/Column trees.
class DashboardMenuCard extends StatelessWidget {
  const DashboardMenuCard({
    super.key,
    required this.assetPath,
    required this.label,
    required this.onTap,
    this.width = 150,
    this.height = 150,
    this.color = Colors.green,
    this.maxLines = 1,
  });

  final String assetPath;
  final String label;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Color color;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath, color: color, width: 80, height: 50),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: maxLines,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
