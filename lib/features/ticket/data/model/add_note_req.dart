import 'package:file_picker/file_picker.dart';

class AddNoteReq {
  final String ticketUuid;
  final String remarks;
  final String status;
  final String visibility;
  final List<PlatformFile>? files;
  final List<String> fileIds;

  const AddNoteReq({
    required this.ticketUuid,
    required this.remarks,
    required this.status,
    required this.visibility,
    this.files,
    this.fileIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'remarks': remarks,
      'status': status,
      'visibility': visibility,
      'fileIds': fileIds,
    };
  }

  AddNoteReq copyWith({
    String? ticketUuid,
    String? remarks,
    String? status,
    String? visibility,
    List<PlatformFile>? files,
    List<String>? fileIds,
  }) {
    return AddNoteReq(
      ticketUuid: ticketUuid ?? this.ticketUuid,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      files: files ?? this.files,
      fileIds: fileIds ?? this.fileIds,
    );
  }
}
