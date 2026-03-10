import 'package:kfon_subscriber/features/ticket/domain/entity/submit_ticket_respo_entity.dart';

class SubmitTicketRespo {
  final String ticketId;
  final String ticketUuid;
  final String status;

  const SubmitTicketRespo({
    required this.ticketId,
    required this.ticketUuid,
    required this.status,
  });

  factory SubmitTicketRespo.fromJson(Map<String, dynamic> json) {
    return SubmitTicketRespo(
      ticketId: json['id']?.toString() ?? '',
      ticketUuid: json['ticketId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  SubmitTicketRespoEntity toEntity() {
    return SubmitTicketRespoEntity(
      ticketId: ticketId,
      ticketUuid: ticketUuid,
      status: status,
    );
  }
}
