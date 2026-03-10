import 'package:kfon_subscriber/features/ticket/domain/entity/add_note_respo_entity.dart';

class AddNoteRespo {
  final String movementId;
  final String ticketId;
  final String status;
  final String? assignedToName;
  final String? modifiedDate;

  const AddNoteRespo({
    required this.movementId,
    required this.ticketId,
    required this.status,
    this.assignedToName,
    this.modifiedDate,
  });

  factory AddNoteRespo.fromJson(Map<String, dynamic> json) {
    return AddNoteRespo(
      movementId: json['movementId']?.toString() ?? '',
      ticketId: json['ticketId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      assignedToName: json['assignedToName']?.toString(),
      modifiedDate: json['modifiedDate']?.toString(),
    );
  }

  AddNoteRespoEntity toEntity() {
    return AddNoteRespoEntity(
      movementId: movementId,
      ticketId: ticketId,
      status: status,
      assignedToName: assignedToName,
      modifiedDate: modifiedDate,
    );
  }
}
