import 'package:file_picker/file_picker.dart';

class SubmitTicketReq {
  final String subjectId;
  final String ticketCategory;
  final String priority;
  final String remarks;
  final String customerType;
  final String customerId;
  final String customerName;
  final String subjectResolve;
  final List<PlatformFile>? files;

  SubmitTicketReq({
    required this.subjectId,
    required this.ticketCategory,
    required this.priority,
    required this.remarks,
    required this.customerType,
    required this.customerId,
    required this.customerName,
    required this.subjectResolve,
    this.files,
  });

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'ticketCategory': ticketCategory,
      'priority': priority,
      'remarks': remarks,
      'customerType': customerType,
      'customerId': customerId,
      'customerName': customerName,
      'subjectResolve': subjectResolve,
    };
  }
}
