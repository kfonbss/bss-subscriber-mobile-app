import 'package:kfon_subscriber/features/ticket/domain/entity/customer_type_entity.dart';

class CustomerTypeModel {
  final String id;
  final String code;
  final String name;
  final bool isActive;

  const CustomerTypeModel({
    required this.id,
    required this.code,
    required this.name,
    required this.isActive,
  });

  factory CustomerTypeModel.fromJson(Map<String, dynamic> json) {
    return CustomerTypeModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  CustomerTypeEntity toEntity() {
    return CustomerTypeEntity(
      id: id,
      code: code,
      name: name,
      isActive: isActive,
    );
  }
}
