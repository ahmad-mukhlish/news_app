class PushNotification {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final Map<String, dynamic>? data;
  final bool isRead;

  PushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.data,
    this.isRead = false,
  });

  PushNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? receivedAt,
    Map<String, dynamic>? data,
    bool? isRead,
  }) {
    return PushNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
    );
  }
}
