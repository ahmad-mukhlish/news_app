class PushNotification {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final bool isRead;

  PushNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.data,
    this.imageUrl,
    this.isRead = false,
  });

  PushNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? receivedAt,
    Map<String, dynamic>? data,
    String? imageUrl,
    bool? isRead,
  }) {
    return PushNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
    );
  }
}
