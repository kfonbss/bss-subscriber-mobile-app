abstract class NotificationEvent {
  const NotificationEvent();
}

class LoadNotifications extends NotificationEvent {
  final int page;
  final int size;
  final String status;

  const LoadNotifications({
    this.page = 0,
    this.size = 20,
    this.status = 'UNREAD',
  });
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}
