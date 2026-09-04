// Notification Badge Widget
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

import '../../notification/screen/user_notification_screen.dart';
import '../../notification/service/user_notification_service.dart';

class NotificationBadgeWidget extends StatelessWidget {
  const NotificationBadgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final _notificationService = UserNotificationService();

    return FutureBuilder<List<String>>(
      future: _notificationService.getAdminDocIds(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Icon(Icons.notifications);

        final adminDocIds = snapshot.data!;
        return StreamBuilder<int>(
          stream: _notificationService.getTotalUnreadCount(adminDocIds),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return badges.Badge(
              showBadge: count > 0,
              badgeContent: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10)),
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.green,
                padding: const EdgeInsets.all(6),
                borderRadius: BorderRadius.circular(8),
                elevation: 4,
                borderSide: const BorderSide(color: Colors.white, width: 1),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>
                        UserNotificationScreen(adminDocIds: adminDocIds)),
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