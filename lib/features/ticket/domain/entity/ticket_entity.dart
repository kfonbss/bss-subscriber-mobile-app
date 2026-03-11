class TicketAttachmentEntity {
  final String id;
  final String fileUrl;
  final String filePath;
  final String? fileId;
  final String? movementId;
  final String fileType;

  const TicketAttachmentEntity({
    required this.id,
    required this.fileUrl,
    required this.filePath,
    this.fileId,
    this.movementId,
    required this.fileType,
  });
}

class TicketSubjectEntity {
  final String id;
  final String code;
  final String name;
  final String? nameInLocal;
  final bool isActive;

  const TicketSubjectEntity({
    required this.id,
    required this.code,
    required this.name,
    this.nameInLocal,
    required this.isActive,
  });
}

class TicketMovementEntity {
  final String id;
  final String? note;
  final String status;
  final String? assignedToName;
  final DateTime? createdDate;
  final List<String> imageUrl;
  final List<String> videoUrl;

  const TicketMovementEntity({
    required this.id,
    this.note,
    required this.status,
    this.assignedToName,
    this.createdDate,
    this.imageUrl = const [],
    this.videoUrl = const [],
  });
}

class TicketEntity {
  final String uuid;
  final int? ticketId;
  final DateTime? submitDate;
  final DateTime? dueDate;
  final String status;
  final String priority;
  final TicketSubjectEntity? subject;
  final String? ticketType;
  final String? customerType;
  final String? createdByUser;
  final String? partnerUuid;
  final String? subscriberUuid;
  final String? partnerName;
  final String? subscriber;
  final String? subjectResolve;
  final String? slaStatus;
  final String? assignedToName;
  final String? mobileNumber;
  final String? remarks;
  final List<TicketAttachmentEntity> attachments;
  final List<TicketMovementEntity> movements;

  const TicketEntity({
    required this.uuid,
    this.ticketId,
    this.submitDate,
    this.dueDate,
    required this.status,
    required this.priority,
    this.subject,
    this.ticketType,
    this.customerType,
    this.createdByUser,
    this.partnerUuid,
    this.subscriberUuid,
    this.partnerName,
    this.subscriber,
    this.subjectResolve,
    this.slaStatus,
    this.assignedToName,
    this.mobileNumber,
    this.remarks,
    this.attachments = const [],
    this.movements = const [],
  });
}
