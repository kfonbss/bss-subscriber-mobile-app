class AddNoteRespoEntity {
  final String movementId;
  final String ticketId;
  final String status;
  final String? assignedToName;
  final String? modifiedDate;

  const AddNoteRespoEntity({
    required this.movementId,
    required this.ticketId,
    required this.status,
    this.assignedToName,
    this.modifiedDate,
  });
}
