class NotificationEntity {
  final String id;
  final String notificationId;
  final String module;
  final String eventType;
  final String category;
  final String title;
  final String body;
  final String? actionUrl;
  final String? referenceType;
  final String? referenceId;
  final String? senderName;
  final Map<String, dynamic>? metadata;
  final bool read;
  final DateTime? createdDate;

  const NotificationEntity({
    required this.id,
    required this.notificationId,
    required this.module,
    required this.eventType,
    required this.category,
    required this.title,
    required this.body,
    this.actionUrl,
    this.referenceType,
    this.referenceId,
    this.senderName,
    this.metadata,
    required this.read,
    this.createdDate,
  });
}
