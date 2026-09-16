import 'package:flutter/material.dart';

class EditUserInfo extends StatelessWidget {
  const EditUserInfo({
    super.key,
    required this.name,
    required this.email,
    required this.userId,
  });

  final String name;
  final String email;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(name),
        subtitle: Text(email),
        trailing: Text('ID: $userId'),
      ),
    );
  }
}