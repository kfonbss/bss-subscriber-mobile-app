import '../entity/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications({
    int page = 0,
    int size = 20,
    String status = 'UNREAD',
  });

  Future<void> markAllAsRead();

  Future<int> getUnreadCount();
}
