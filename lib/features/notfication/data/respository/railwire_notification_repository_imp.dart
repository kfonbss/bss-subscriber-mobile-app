import 'package:kfon_subscriber/features/notfication/domain/entity/notification_entity.dart';
import 'package:kfon_subscriber/features/notfication/domain/respository/notification_repository.dart';

/// RailWire has no notifications API yet, so nothing is called: there are no
/// notifications and nothing unread.
class RailwireNotificationRepositoryImp implements NotificationRepository {
  @override
  Future<List<NotificationEntity>> getNotifications({
    int page = 0,
    int size = 20,
    String status = 'UNREAD',
  }) async => [];

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<int> getUnreadCount() async => 0;
}
