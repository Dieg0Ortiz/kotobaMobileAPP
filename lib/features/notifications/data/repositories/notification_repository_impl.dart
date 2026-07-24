import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/kotoba_notification.dart';
import '../../domain/repositories/i_notification_repository.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final ApiClient _api;

  NotificationRepositoryImpl(this._api);

  @override
  Future<Either<Failure, ({List<KotobaNotification> notifications, int unreadCount})>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return result.fold(
      (f) => Left(f),
      (data) {
        final list = (data['notifications'] as List<dynamic>?)
                ?.map((e) => KotobaNotification.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];
        final count = data['unreadCount'] as int? ?? 0;
        return Right((notifications: list, unreadCount: count));
      },
    );
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    final result = await _api.get<Map<String, dynamic>>(
      ApiConstants.notificationsUnreadCount,
    );
    return result.fold(
      (f) => Left(f),
      (data) => Right(data['count'] as int? ?? 0),
    );
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    final result = await _api.put<dynamic>(
      ApiConstants.notificationById(notificationId) + '/read',
    );
    return result.fold(
      (f) => Left(f),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    final result = await _api.put<dynamic>(
      ApiConstants.notificationsReadAll,
    );
    return result.fold(
      (f) => Left(f),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> delete(String notificationId) async {
    final result = await _api.delete<dynamic>(
      ApiConstants.notificationById(notificationId),
    );
    return result.fold(
      (f) => Left(f),
      (_) => const Right(null),
    );
  }
}
