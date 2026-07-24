import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kotoba_colors.dart';
import '../../../../core/theme/kotoba_typography.dart';
import '../providers/notification_providers.dart';
import '../../domain/entities/kotoba_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KotobaColors.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: c.surface,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.onSurface),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Text('Notificaciones', style: KotobaTypography.headlineMd.copyWith(color: c.onSurface)),
        actions: [
          TextButton(
            onPressed: () async {
              final repo = ref.read(notificationRepositoryProvider);
              await repo.markAllAsRead();
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: Text('Marcar todo leído', style: KotobaTypography.labelMd.copyWith(color: c.primary)),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: c.error))),
        data: (result) {
          final notifications = result.notifications;
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: c.outlineVariant),
                  const SizedBox(height: 16),
                  Text('No tienes notificaciones', style: KotobaTypography.bodyMd.copyWith(color: c.onSurfaceVariant)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: c.outlineVariant.withValues(alpha: 0.2)),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationTile(
                  notification: notif,
                  onTap: () async {
                    if (!notif.read) {
                      final repo = ref.read(notificationRepositoryProvider);
                      await repo.markAsRead(notif.id);
                      ref.invalidate(notificationsProvider);
                      ref.invalidate(unreadCountProvider);
                    }
                    _handleTap(context, notif);
                  },
                  onDelete: () async {
                    final repo = ref.read(notificationRepositoryProvider);
                    await repo.delete(notif.id);
                    ref.invalidate(notificationsProvider);
                    ref.invalidate(unreadCountProvider);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, KotobaNotification notif) {
    final data = notif.data;
    if (notif.type == 'tip_received') {
      context.go('/dashboard');
    } else if (notif.type == 'new_story' && data != null && data['workId'] != null) {
      context.push('/works/${data['workId']}');
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final KotobaNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'tip_received':
        return Icons.attach_money;
      case 'new_story':
        return Icons.auto_stories;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type, BuildContext context) {
    final c = KotobaColors.of(context);
    switch (type) {
      case 'tip_received':
        return const Color(0xFF2E7D32);
      case 'new_story':
        return c.primary;
      default:
        return c.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = KotobaColors.of(context);
    final timeAgo = _formatTimeAgo(notification.createdAt);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: c.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color: notification.read ? Colors.transparent : c.primary.withValues(alpha: 0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _colorForType(notification.type, context).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(_iconForType(notification.type), size: 20, color: _colorForType(notification.type, context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: KotobaTypography.labelMd.copyWith(
                        color: c.onSurface,
                        fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: KotobaTypography.labelSm.copyWith(color: c.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(timeAgo, style: KotobaTypography.labelXs.copyWith(color: c.outlineVariant)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }
}
