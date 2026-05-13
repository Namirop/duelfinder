import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tcg_matchmaker/features/notifications/entities/notification.dart';
import 'package:tcg_matchmaker/features/notifications/entities/notifications_state.dart';
import 'package:tcg_matchmaker/features/notifications/providers/notifications_provider.dart';
import 'package:tcg_matchmaker/shared/widgets/app_error_widget.dart';
import 'package:tcg_matchmaker/shared/widgets/loading_widget.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsNotifierProvider.notifier).markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: theme.textTheme.titleMedium?.copyWith(fontSize: 23),
        ),
      ),
      body: _buildBody(theme, colorScheme, state),
    );
  }

  Widget _buildBody(
      ThemeData theme, ColorScheme colorScheme, NotificationsState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const LoadingWidget();
    }

    if (state.error != null && state.notifications.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref
            .read(notificationsNotifierProvider.notifier)
            .fetchNotifications(),
      );
    }

    if (state.notifications.isEmpty) {
      return _buildEmpty(theme, colorScheme);
    }

    return _buildList(state.notifications, colorScheme);
  }

  Widget _buildList(
      List<AppNotification> notifications, ColorScheme colorScheme) {
    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.4),
      ),
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return _NotificationTile(
          notif: notif,
          onDelete: () => ref
              .read(notificationsNotifierProvider.notifier)
              .deleteNotification(notif.id),
        );
      },
    );
  }

  Widget _buildEmpty(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 56,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune notification',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onDelete;

  const _NotificationTile({required this.notif, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final iconColor = notif.colorFor(colorScheme);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: colorScheme.errorContainer,
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(notif.icon, color: iconColor, size: 20),
        ),
        title: Text(
          notif.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: notif.read ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              notif.body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _timeAgo(notif.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
        trailing: notif.read
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${date.day}/${date.month}/${date.year}';
  }
}
