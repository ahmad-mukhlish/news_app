import 'package:intl/intl.dart';

/// Format DateTime to human-readable time ago string
/// Examples: "Just now", "5m ago", "3h ago", "2d ago", "Jan 15, 2024"
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
}
