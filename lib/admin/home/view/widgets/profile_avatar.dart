import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.imageStream,
    required this.onTap,
  });

  final Stream<String> imageStream;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: imageStream,
      builder: (context, snapshot) {
        final profileImage = snapshot.data ?? '';

        return GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.shade300, width: 2),
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
                          placeholder: (context, url) => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            color: Colors.red,
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.red),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
