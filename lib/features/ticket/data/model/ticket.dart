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

/// Splits movement media arrays into direct URLs vs [fileId] references.
class _MovementMediaParse {
  _MovementMediaParse({required this.urls, required this.fileIds});

  final List<String> urls;
  final List<String> fileIds;
}

_MovementMediaParse _parseMovementMediaList(dynamic raw) {
  final urls = <String>[];
  final fileIds = <String>[];
  if (raw is! List<dynamic>) {
    return _MovementMediaParse(urls: urls, fileIds: fileIds);
  }
  for (final e in raw) {
    if (e is Map<String, dynamic>) {
      final fid = e['fileId']?.toString();
      if (fid != null && fid.isNotEmpty) {
        fileIds.add(fid);
      }
    } else if (e is String) {
      final s = e.trim();
      if (s.isEmpty) continue;
      if (s.startsWith('http') || s.startsWith('/') || s.contains('://')) {
        urls.add(s);
      } else {
        fileIds.add(s);
      }
    }
  }
  return _MovementMediaParse(urls: urls, fileIds: fileIds);
}

class TicketMovement {
  final String id;
  final String? note;
  final String status;
  final String? assignedToName;
  final String? assignedFromName;
  final String? assignedFromDesignation;
  final String? assignedToSeatName;
  final String? assignedFromSeatName;
  final DateTime? createdDate;
  final List<String> imageUrl;
  final List<String> videoUrl;
  final List<String> documentUrl;
  final List<String> imageFileIds;
  final List<String> videoFileIds;
  final List<String> documentFileIds;

  const TicketMovement({
    required this.id,
    this.note,
    required this.status,
    this.assignedToName,
    this.assignedFromName,
    this.assignedFromDesignation,
    this.assignedToSeatName,
    this.assignedFromSeatName,
    this.createdDate,
    this.imageUrl = const [],
    this.videoUrl = const [],
    this.documentUrl = const [],
    this.imageFileIds = const [],
    this.videoFileIds = const [],
    this.documentFileIds = const [],
  });

  factory TicketMovement.fromJson(Map<String, dynamic> json) {
    final image = _parseMovementMediaList(json['imageUrl']);
    final video = _parseMovementMediaList(json['videoUrl']);
    final doc = _parseMovementMediaList(json['documentUrl']);

    return TicketMovement(
      id: json['id']?.toString() ?? '',
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? '',
      assignedToName: json['assignedToName']?.toString(),
      assignedFromName: json['assignedFromName']?.toString(),

      assignedFromDesignation: json['assignedFromDesignation']?.toString(),

      assignedFromSeatName: json['assignedFromSeatName']?.toString(),

      assignedToSeatName: json['assignedToSeatName']?.toString(),
      createdDate:
          json['createdDate'] != null
              ? DateTime.tryParse(json['createdDate'] as String)
              : null,
      imageUrl: image.urls,
      videoUrl: video.urls,
      documentUrl: doc.urls,
      imageFileIds: image.fileIds,
      videoFileIds: video.fileIds,
      documentFileIds: doc.fileIds,
    );
  }

  TicketMovementEntity toEntity() {
    return TicketMovementEntity(
      id: id,
      note: note,
      status: status,
      assignedToName: assignedToName,
      assignedFromName: assignedFromName,

      assignedToSeatName: assignedToSeatName,
      assignedFromSeatName: assignedFromSeatName,
      assignedFromDesignation: assignedFromDesignation,

      createdDate: createdDate,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      documentUrl: documentUrl,
      imageFileIds: imageFileIds,
      videoFileIds: videoFileIds,
      documentFileIds: documentFileIds,
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
  final TicketGstinDetails? gstinDetails;
  final int? rating;
  final String? ratingComment;

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
    this.gstinDetails,
    this.rating,
    this.ratingComment,
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
      // GST and PAN Updation tickets return their values in `requestData`.
      gstinDetails:
          json['requestData'] is Map<String, dynamic>
              ? TicketGstinDetails.fromJson(
                json['requestData'] as Map<String, dynamic>,
              )
              : null,
      // TODO(rating): placeholder keys — confirm with the ticket API.
      rating: int.tryParse(json['rating']?.toString() ?? ''),
      ratingComment: json['ratingComment']?.toString(),
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
      'requestData': gstinDetails?.toJson(),
      'rating': rating,
      'ratingComment': ratingComment,
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
      gstinDetails: gstinDetails?.toEntity(),
      rating: rating,
      ratingComment: ratingComment,
    );
  }
}

/// `requestData` on GST and PAN Updation tickets.
class TicketGstinDetails {
  final String type;
  final String typeName;
  final String pan;
  final String gstin;
  final String serviceDescription;
  final String sac;
  final String taxPayerType;
  final String legalName;
  final String tradeName;
  final String? gstDocFileId;
  final String? panCopyFileId;

  const TicketGstinDetails({
    this.type = '',
    this.typeName = '',
    required this.pan,
    required this.gstin,
    required this.serviceDescription,
    required this.sac,
    required this.taxPayerType,
    this.legalName = '',
    this.tradeName = '',
    this.gstDocFileId,
    this.panCopyFileId,
  });

  factory TicketGstinDetails.fromJson(Map<String, dynamic> json) {
    String str(String key) => json[key]?.toString().trim() ?? '';
    String? id(String key) {
      final v = str(key);
      return v.isEmpty ? null : v;
    }

    return TicketGstinDetails(
      type: str('type'),
      typeName: str('typeName'),
      pan: str('pan'),
      gstin: str('gstin'),
      serviceDescription: str('serviceDescription'),
      sac: str('sac'),
      taxPayerType: str('taxPayerType'),
      legalName: str('legalName'),
      tradeName: str('tradeName'),
      gstDocFileId: id('gstDocFileId'),
      panCopyFileId: id('panCopyFileId'),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'typeName': typeName,
    'pan': pan,
    'gstin': gstin,
    'serviceDescription': serviceDescription,
    'sac': sac,
    'taxPayerType': taxPayerType,
    'legalName': legalName,
    'tradeName': tradeName,
    'gstDocFileId': gstDocFileId,
    'panCopyFileId': panCopyFileId,
  };

  TicketGstinDetailsEntity toEntity() => TicketGstinDetailsEntity(
    type: type,
    typeName: typeName,
    pan: pan,
    gstin: gstin,
    serviceDescription: serviceDescription,
    sac: sac,
    taxPayerType: taxPayerType,
    legalName: legalName,
    tradeName: tradeName,
    gstDocFileId: gstDocFileId,
    panCopyFileId: panCopyFileId,
  );
}
