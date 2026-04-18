import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tcg_matchmaker/core/router/app_router.dart';
import 'package:tcg_matchmaker/features/notifications/providers/notifications_provider.dart';

class NotificationIconButton extends ConsumerWidget {
  final ColorScheme colorScheme;

  const NotificationIconButton({super.key, required this.colorScheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(notificationsNotifierProvider).hasUnread;

    return IconButton(
      onPressed: () => context.push(AppRoutes.notifications),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
          if (hasUnread)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
