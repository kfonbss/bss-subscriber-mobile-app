import '../../domain/entity/tenant_entity.dart';

class TenantModel {
  final String  id;
  final String  code;
  final String  name;
  final String? nameInLocal;
  final bool    isActive;

  const TenantModel({
    required this.id,
    required this.code,
    required this.name,
    this.nameInLocal,
    required this.isActive,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) => TenantModel(
    id:          json['id']          as String? ?? '',
    code:        json['code']        as String? ?? '',
    name:        json['name']        as String? ?? '',
    nameInLocal: json['nameInLocal'] as String?,
    isActive:    json['isActive']    as bool?   ?? true,
  );

  TenantEntity toEntity() => TenantEntity(
    id:          id,
    code:        code,
    name:        name,
    nameInLocal: nameInLocal,
    isActive:    isActive,
  );
}