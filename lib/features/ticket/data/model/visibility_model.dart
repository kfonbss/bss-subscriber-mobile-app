import 'package:kfon_subscriber/features/ticket/domain/entity/visibility_entity.dart';

class VisibilityModel {
  final String code;
  final String name;
  final bool isActive;

  const VisibilityModel({
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory VisibilityModel.fromJson(Map<String, dynamic> json) {
    return VisibilityModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  VisibilityEntity toEntity() {
    return VisibilityEntity(
      code: code,
      name: name,
      isActive: isActive,
    );
  }
}
