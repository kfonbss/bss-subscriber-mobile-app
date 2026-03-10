import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_entity.dart';

class TicketAttachment {
  final String id;
  final String fileUrl;
  final String filePath;
  final String? fileId;
  final String? movementId;
  final String fileType;

  const TicketAttachment({
    required this.id,
    required this.fileUrl,
    required this.filePath,
    this.fileId,
    this.movementId,
    required this.fileType,
  });

  factory TicketAttachment.fromJson(Map<String, dynamic> json) {
    return TicketAttachment(
      id: json['id']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      filePath: json['filePath']?.toString() ?? '',
      fileId: json['fileId']?.toString(),
      movementId: json['movementId']?.toString(),
      fileType: json['fileType']?.toString() ?? '',
    );
  }

  TicketAttachmentEntity toEntity() {
    return TicketAttachmentEntity(
      id: id,
      fileUrl: fileUrl,
      filePath: filePath,
      fileId: fileId,
      movementId: movementId,
      fileType: fileType,
    );
  }
}

class TicketSubject {
  final String id;
  final String code;
  final String name;
  final String? nameInLocal;
  final bool isActive;

  const TicketSubject({
    required this.id,
    required this.code,
    required this.name,
    this.nameInLocal,
    required this.isActive,
  });

  factory TicketSubject.fromJson(Map<String, dynamic> json) {
    return TicketSubject(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString().trim() ?? '',
      name: json['name']?.toString() ?? '',
      nameInLocal: json['nameInLocal']?.toString(),
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  TicketSubjectEntity toEntity() {
    return TicketSubjectEntity(
      id: id,
      code: code,
      name: name,
      nameInLocal: nameInLocal,
      isActive: isActive,
    );
  }
}

class TicketMovement {
  final String id;
  final String? note;
  final String status;
  final String? assignedToName;
  final DateTime? createdDate;
  final List<String> imageUrl;
  final List<String> videoUrl;

  const TicketMovement({
    required this.id,
    this.note,
    required this.status,
    this.assignedToName,
    this.createdDate,
    this.imageUrl = const [],
    this.videoUrl = const [],
  });

  factory TicketMovement.fromJson(Map<String, dynamic> json) {
    return TicketMovement(
      id: json['id']?.toString() ?? '',
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? '',
      assignedToName: json['assignedToName']?.toString(),
      createdDate:
          json['createdDate'] != null
              ? DateTime.tryParse(json['createdDate'] as String)
              : null,
      imageUrl:
          (json['imageUrl'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      videoUrl:
          (json['videoUrl'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  TicketMovementEntity toEntity() {
    return TicketMovementEntity(
      id: id,
      note: note,
      status: status,
      assignedToName: assignedToName,
      createdDate: createdDate,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
    );
  }
}

class Ticket {
  final String id;
  final int? ticketId;
  final DateTime? submitDate;
  final DateTime? dueDate;
  final String status;
  final String priority;
  final TicketSubject? subject;
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
  final List<TicketAttachment> attachments;
  final List<TicketMovement> movements;

  const Ticket({
    required this.id,
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

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id']?.toString() ?? '',
      ticketId: json['ticketId'] as int?,
      submitDate:
          json['submitDate'] != null
              ? DateTime.tryParse(json['submitDate'] as String)
              : null,
      dueDate:
          json['dueDate'] != null
              ? DateTime.tryParse(json['dueDate'] as String)
              : null,
      status: json['status']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      subject:
          json['subject'] != null
              ? TicketSubject.fromJson(json['subject'] as Map<String, dynamic>)
              : null,
      ticketType: json['ticketType']?.toString(),
      customerType: json['customerType']?.toString(),
      createdByUser: json['createdByUser']?.toString(),
      partnerUuid: json['partnerUuid']?.toString(),
      subscriberUuid: json['subscriberUuid']?.toString(),
      partnerName: json['partnerName']?.toString(),
      subscriber: json['subscriber']?.toString(),
      subjectResolve: json['subjectResolve']?.toString(),
      slaStatus: json['slaStatus']?.toString(),
      assignedToName: json['assignedToName']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      remarks: json['remarks']?.toString(),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => TicketAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      movements:
          (json['movements'] as List<dynamic>?)
              ?.map((e) => TicketMovement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'submitDate': submitDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'priority': priority,
      'subject':
          subject != null
              ? {
                'id': subject!.id,
                'code': subject!.code,
                'name': subject!.name,
                'nameInLocal': subject!.nameInLocal,
                'isActive': subject!.isActive,
              }
              : null,
      'ticketType': ticketType,
      'customerType': customerType,
      'createdByUser': createdByUser,
      'partnerUuid': partnerUuid,
      'subscriberUuid': subscriberUuid,
      'partnerName': partnerName,
      'subscriber': subscriber,
      'subjectResolve': subjectResolve,
      'slaStatus': slaStatus,
      'assignedToName': assignedToName,
      'mobileNumber': mobileNumber,
      'remarks': remarks,
    };
  }

  TicketEntity toEntity() {
    return TicketEntity(
      uuid: id,
      ticketId: ticketId,
      submitDate: submitDate,
      dueDate: dueDate,
      status: status,
      priority: priority,
      subject: subject?.toEntity(),
      ticketType: ticketType,
      customerType: customerType,
      createdByUser: createdByUser,
      partnerUuid: partnerUuid,
      subscriberUuid: subscriberUuid,
      partnerName: partnerName,
      subscriber: subscriber,
      subjectResolve: subjectResolve,
      slaStatus: slaStatus,
      assignedToName: assignedToName,
      mobileNumber: mobileNumber,
      remarks: remarks,
      attachments: attachments.map((e) => e.toEntity()).toList(),
      movements: movements.map((e) => e.toEntity()).toList(),
    );
  }
}
