import 'package:flutter/material.dart';

class UpdateButton extends StatelessWidget {
  const UpdateButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,

      child: ElevatedButton.icon(
        onPressed:
        isLoading ? null : onPressed,

        icon: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.save),

        label: Text(
          isLoading
              ? 'Updating...'
              : 'Update Money',
        ),
      ),
    );
  }
}