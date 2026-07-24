import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/kotoba_notification.dart';
import '../../domain/repositories/i_notification_repository.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  final api = ref.read(contentApiClientProvider);
  return NotificationRepositoryImpl(api);
});

final notificationsProvider = FutureProvider<({List<KotobaNotification> notifications, int unreadCount})>((ref) async {
  final isLoggedIn = ref.watch(authStateProvider);
  if (!isLoggedIn) return (notifications: <KotobaNotification>[], unreadCount: 0);
  final repo = ref.read(notificationRepositoryProvider);
  final result = await repo.getNotifications();
  return result.fold(
    (f) => throw f,
    (data) => data,
  );
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final isLoggedIn = ref.watch(authStateProvider);
  if (!isLoggedIn) return 0;
  final repo = ref.read(notificationRepositoryProvider);
  final result = await repo.getUnreadCount();
  return result.fold(
    (f) => 0,
    (count) => count,
  );
});
