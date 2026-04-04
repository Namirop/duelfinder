import 'package:tcg_matchmaker/features/notifications/entities/notification.dart';

class NotificationsState {
  final List<AppNotification> notifications;

  const NotificationsState({this.notifications = const []});

  bool get hasUnread => notifications.any((n) => !n.read);

  NotificationsState copyWith({List<AppNotification>? notifications}) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
    );
  }
}
