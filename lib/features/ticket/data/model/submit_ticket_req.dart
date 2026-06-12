import 'package:file_picker/file_picker.dart';

class SubmitTicketReq {
  final String subjectId;
  final String ticketCategory;
  final String? priority;
  final String remarks;
  final String customerType;
  final String customerId;
  final String customerName;
  final String subjectResolve;
  final List<PlatformFile>? files;

  SubmitTicketReq({
    required this.subjectId,
    required this.ticketCategory,
    this.priority,
    required this.remarks,
    required this.customerType,
    required this.customerId,
    required this.customerName,
    required this.subjectResolve,
    this.files,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': ticketCategory,     // UUID from category picker
      'subjectId': subjectId,
      'priority': priority,
      'customerTypeId': customerType,   // UUID from customer type
      'customerId': customerId,
      'customerName': customerName,
      'remarks': remarks,
      'subjectResolve': subjectResolve,
    };
  }
}
