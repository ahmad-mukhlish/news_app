class PushNotificationDto {
  final String? id;
  final String? title;
  final String? body;
  final String? receivedAt;
  final Map<String, dynamic>? data;
  final bool? isRead;

  PushNotificationDto({
    this.id,
    this.title,
    this.body,
    this.receivedAt,
    this.data,
    this.isRead,
  });

  factory PushNotificationDto.fromJson(Map<String, dynamic> json) {
    return PushNotificationDto(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      receivedAt: json['receivedAt'],
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      isRead: json['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'receivedAt': receivedAt,
      'data': data,
      'isRead': isRead,
    };
  }
}
