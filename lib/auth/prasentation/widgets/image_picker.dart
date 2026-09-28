import 'dart:io';

import 'package:flutter/material.dart';

/// Circular avatar with a green border used to pick / show the profile
/// image. Shows a camera icon until an image is selected.
class ProfileImagePicker extends StatelessWidget {

  const ProfileImagePicker({
    super.key,
    required this.image,
    required this.onTap,
  });

  final File? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 55,
          backgroundColor: Colors.grey.shade200,
          backgroundImage:
          image != null
              ? FileImage(image!)
              : null,
          child: image == null
              ? const Icon(
            Icons.camera_alt,
            size: 35,
            color: Colors.green,
          )
              : null,
        ),
      ),
    );
  }
}
