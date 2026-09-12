import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

import '../../../notification/screen/notificationlist_screen.dart';
import '../../../notification/service/note_service.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({
    super.key,
    required this.noteService,
    required this.adminDocId,
  });

  final NoteService noteService;
  final String adminDocId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: noteService.getAdminDocIds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Icon(Icons.notifications);
        final adminDocIds = snapshot.data!;

        return StreamBuilder<int>(
          stream: noteService.getTotalUnreadCount(adminDocIds),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;

            return badges.Badge(
              showBadge: count > 0,
              badgeAnimation: badges.BadgeAnimation.scale(),
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.green,
                padding: const EdgeInsets.all(6),
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white, width: 1),
                elevation: 4,
              ),
              badgeContent: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NotificationListScreen(adminDocId: adminDocId),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
