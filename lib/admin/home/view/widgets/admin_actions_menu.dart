import 'package:flutter/material.dart';

enum AdminAction { logout, profile, contact, aboutDeveloper }

class AdminActionsMenu extends StatelessWidget {
  const AdminActionsMenu({super.key, required this.onSelected});

  final ValueChanged<AdminAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AdminAction>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: AdminAction.logout,
          child: Row(
            children: [
              Icon(Icons.login, color: Colors.black),
              SizedBox(width: 10),
              Text('Logout'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: AdminAction.profile,
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.black),
              SizedBox(width: 10),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AdminAction.contact,
          child: Row(
            children: [
              Image.asset('assets/images/contact-mail.png', height: 20, width: 20),
              const SizedBox(width: 10),
              const Text('Contact'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AdminAction.aboutDeveloper,
          child: Row(
            children: [
              Image.asset('assets/images/coding.png', height: 20, width: 20),
              const SizedBox(width: 10),
              const Text('About Developer'),
            ],
          ),
        ),
      ],
    );
  }
}
