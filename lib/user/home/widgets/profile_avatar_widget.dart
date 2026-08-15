/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../../profile/screen/profile_screen.dart';
import '../presentation/controller/home_controller.dart';

class ProfileAvatarWidget extends StatelessWidget {
  const ProfileAvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final profileImage =
          controller.user.value?.profileImage ?? '';

      final docId =
          controller.user.value?.uid ?? '';

      return GestureDetector(
        onTap: () {
          Get.to(
                () => UserProfileScreen(
              userId: docId,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.redAccent,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              child: ClipOval(
                child: profileImage.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: profileImage,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                  const CircularProgressIndicator(),
                  errorWidget: (_, __, ___) =>
                  const Icon(Icons.person),
                )
                    : const Icon(
                  Icons.person,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}*/
