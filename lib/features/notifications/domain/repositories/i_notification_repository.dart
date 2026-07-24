import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/kotoba_notification.dart';

abstract class INotificationRepository {
  Future<Either<Failure, ({List<KotobaNotification> notifications, int unreadCount})>> getNotifications({int limit, int offset});
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead();
  Future<Either<Failure, void>> delete(String notificationId);
}
