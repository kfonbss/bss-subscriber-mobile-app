class AddNoteReq {
  final String ticketUuid;
  final String remarks;
  final String status;
  final String visibility;

  const AddNoteReq({
    required this.ticketUuid,
    required this.remarks,
    required this.status,
    required this.visibility,
  });

  Map<String, dynamic> toJson() {
    return {
      'remarks': remarks,
      'status': status,
      'visibility': visibility,
    };
  }
}
