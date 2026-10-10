import 'package:kfon_subscriber/features/ticket/domain/entity/priority_entity.dart';

class PriorityModel {
  final String code;
  final String name;
  final bool isActive;

  const PriorityModel({
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory PriorityModel.fromJson(Map<String, dynamic> json) {
    return PriorityModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  PriorityEntity toEntity() {
    return PriorityEntity(code: code, name: name, isActive: isActive);
  }
}
