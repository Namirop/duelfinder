import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        read: read ?? this.read,
        createdAt: createdAt,
      );

  IconData get icon {
    switch (type) {
      case 'PARTICIPATION_REQUEST':
        return Icons.person_add_outlined;
      case 'PARTICIPATION_ACCEPTED':
        return Icons.check_circle_outline;
      case 'PARTICIPATION_REJECTED':
      case 'PARTICIPATION_CANCELLED':
        return Icons.cancel_outlined;
      case 'NEW_MESSAGE':
        return Icons.chat_bubble_outline;
      case 'GAME_FULL':
        return Icons.group_outlined;
      case 'GAME_CANCELLED':
        return Icons.event_busy_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color colorFor(ColorScheme colorScheme) {
    switch (type) {
      case 'PARTICIPATION_ACCEPTED':
        return colorScheme.primary;
      case 'PARTICIPATION_REJECTED':
      case 'PARTICIPATION_CANCELLED':
      case 'GAME_CANCELLED':
        return colorScheme.error;
      default:
        return colorScheme.secondary;
    }
  }
}
