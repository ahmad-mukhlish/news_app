import 'package:flutter/material.dart';

class NotificationBadgeIcon extends StatelessWidget {
  final int count;
  final bool isActive;

  const NotificationBadgeIcon({
    super.key,
    required this.count,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.tertiary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications_outlined, color: iconColor),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
