import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';

class Subject {
  final String id;
  final String code;
  final String name;
  final String escalationTime;
  final bool isActive;

  const Subject({
    required this.id,
    required this.code,
    required this.name,
    required this.escalationTime,
    required this.isActive,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      escalationTime: json['resolvedTime']?.toString() ?? '2 Hours',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  SubjectEntity toEntity() {
    return SubjectEntity(
      id: id,
      code: code,
      name: name,
      escalationTime: escalationTime,
      isActive: isActive,
    );
  }
}
