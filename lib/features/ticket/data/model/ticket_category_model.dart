import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_category_entity.dart';

class TicketCategoryModel {
  final String id;
  final String code;
  final String name;
  final String nameInLocal;
  final bool isActive;

  const TicketCategoryModel({
    required this.id,
    required this.code,
    required this.name,
    required this.nameInLocal,
    required this.isActive,
  });

  factory TicketCategoryModel.fromJson(Map<String, dynamic> json) {
    return TicketCategoryModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameInLocal: json['nameInLocal'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  TicketCategoryEntity toEntity() {
    return TicketCategoryEntity(
      id: id,
      code: code,
      name: name,
      nameInLocal: nameInLocal,
      isActive: isActive,
    );
  }
}
