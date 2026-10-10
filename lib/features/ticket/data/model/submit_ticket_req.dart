import 'package:file_picker/file_picker.dart';

class SubmitTicketReq {
  final String subjectId;
  final String subjectCode;
  final String ticketCategory;
  final String? priority;
  final String remarks;
  final String customerTypeCode;
  final String customerType;
  final String customerId;
  final String customerName;
  final String subjectResolve;
  final String mobileNumber;
  final List<String> fileIds;
  final List<PlatformFile>? files;

  /// Only for the GST and PAN Updation subject.
  final GstinDetailsReq? gstinDetails;

  SubmitTicketReq({
    required this.subjectId,
    required this.subjectCode,
    required this.ticketCategory,
    this.priority,
    required this.remarks,
    this.customerTypeCode = 'SUBSCRIBERS',
    required this.customerType,
    required this.customerId,
    required this.customerName,
    required this.subjectResolve,
    required this.mobileNumber,
    this.fileIds = const [],
    this.files,
    this.gstinDetails,
  });

  /// [gstDocFileId] / [panCopyFileId] are the IDs returned after uploading
  /// [GstinDetailsReq.gstDocFile] / [GstinDetailsReq.panCopyFile].
  Map<String, dynamic> toJson({String? gstDocFileId, String? panCopyFileId}) {
    return {
      'subjectId': subjectId,
      'code': subjectCode,
      'categoryId': ticketCategory, // UUID from category picker
      'priority': priority,
      'remarks': remarks,
      'customerType': customerTypeCode,
      'customerTypeId': customerType, // UUID from customer type
      'customerId': customerId,
      'customerName': customerName,
      'subjectResolve': subjectResolve,
      'fileIds': fileIds,
      'mobileNumber': mobileNumber,
      if (gstinDetails != null)
        'gstinDetails': gstinDetails!.toJson(
          gstDocFileId: gstDocFileId ?? '',
          panCopyFileId: panCopyFileId ?? '',
        ),
    };
  }
}

class GstinDetailsReq {
  final String pan;
  final String gstin;
  final String serviceDescription;
  final String sac;
  final String taxPayerType;
  final String legalName;
  final String tradeName;
  final PlatformFile gstDocFile;
  final PlatformFile panCopyFile;

  const GstinDetailsReq({
    required this.pan,
    required this.gstin,
    required this.serviceDescription,
    required this.sac,
    required this.taxPayerType,
    this.legalName = '',
    this.tradeName = '',
    required this.gstDocFile,
    required this.panCopyFile,
  });

  Map<String, dynamic> toJson({
    required String gstDocFileId,
    required String panCopyFileId,
  }) {
    return {
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
  }
}
