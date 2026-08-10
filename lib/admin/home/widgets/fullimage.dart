import 'package:flutter/material.dart';

void showImageDialog(
    BuildContext context,
    String imageUrl,
    ) {
  showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
        const EdgeInsets.all(10),
        child: Stack(
          children: [

            InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      height: 300,
                      color: Colors.white,
                      child: const Center(
                        child: Text(
                          'Image not found',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const CircleAvatar(
                  backgroundColor:
                  Colors.black54,
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}