import 'package:flutter/material.dart';

class DeleteIdDialog {
  static Future<bool> show(
      BuildContext context, {
        required String userId,
        required String userName,
        required String type,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text('Delete ID?'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this ID?\n\n'
                'User: $userName\n'
                'User ID: $userId\n'
                'Type: ${type.toUpperCase()}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}