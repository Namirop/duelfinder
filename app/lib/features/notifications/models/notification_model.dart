import 'package:tcg_matchmaker/features/notifications/entities/notification.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        read: json['read'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  AppNotification toEntity() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        read: read,
        createdAt: createdAt,
      );
}
