import 'dart:io';

import 'package:flutter/material.dart';

class ProfileImagePicker extends StatelessWidget {

  final File? image;
  final VoidCallback onTap;

  const ProfileImagePicker({
    super.key,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 55,
        backgroundImage:
        image != null
            ? FileImage(image!)
            : null,
      ),
    );
  }
}