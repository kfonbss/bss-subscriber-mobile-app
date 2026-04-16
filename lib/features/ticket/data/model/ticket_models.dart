import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart';

enum TicketStatus {
  open,
  progress,
  closed,
  resolved;

  static TicketStatus fromString(String status) {
    return switch (status.toLowerCase()) {
      'open' => TicketStatus.open,
      'progress' || 'in progress' => TicketStatus.progress,
      'closed' => TicketStatus.closed,
      'resolved' => TicketStatus.resolved,
      _ => TicketStatus.open,
    };
  }
}

enum TicketPriority {
  instant,
  high,
  medium,
  low;

  static TicketPriority fromString(String priority) {
    return switch (priority.toLowerCase()) {
      'instant' => TicketPriority.instant,
      'high' => TicketPriority.high,
      'medium' => TicketPriority.medium,
      'low' => TicketPriority.low,
      _ => TicketPriority.medium,
    };
  }
}

class TicketItem {
  final String uuid;
  final String title;
  final String? subtitle;
  final String ticketId;
  final TicketStatus status;
  final TicketPriority priority;
  final String resolutionTime;
  final List<TicketAttachmentEntity> attachments;

  TicketItem({
    required this.uuid,
    required this.title,
    this.subtitle,
    required this.ticketId,
    required this.status,
    required this.priority,
    required this.resolutionTime,
    this.attachments = const [],
  });
}

class VisibilityOption {
  final String code;
  final String name;

  const VisibilityOption({required this.code, required this.name});
}
