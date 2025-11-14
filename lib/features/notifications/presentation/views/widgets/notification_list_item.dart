import 'package:flutter/material.dart';

import '../../../../../app/domain/entities/push_notification.dart';
import '../../../../../app/helper/common_methods/date_time_methods.dart';

class NotificationListItem extends StatelessWidget {
  final PushNotification notification;
  final VoidCallback onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final timeAgo = formatTimeAgo(notification.receivedAt);

    return Semantics(
      label: "Notification item",
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isUnread
              ? Colors.blue.withValues(alpha: 0.05)
              : Colors.transparent,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Red dot indicator for unread
              buildReadMarking(isUnread),
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isUnread
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // Chevron icon
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReadMarking(bool isUnread) {
    if (isUnread) return Container();

    return Semantics(
      label: "Unread",
      child: Container(
        width: 8,
        height: 8,
        margin: const EdgeInsets.only(top: 6, right: 12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
      ),
    );
  }
}
