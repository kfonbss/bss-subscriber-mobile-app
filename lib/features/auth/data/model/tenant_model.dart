import '../../domain/entity/tenant_entity.dart';

class TenantModel {
  final String id;
  final String code;
  final String name;
  final String? nameInLocal;
  final bool isActive;
  final String? appUrl;

  const TenantModel({
    required this.id,
    required this.code,
    required this.name,
    this.nameInLocal,
    required this.isActive,
    this.appUrl,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) => TenantModel(
    id: json['id'] as String? ?? '',
    code: json['code'] as String? ?? '',
    name: json['name'] as String? ?? '',
    nameInLocal: json['nameInLocal'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
  );

  /// RailWire states have no id and can share a code (NE2), so the name is
  /// used as the id: the tenant list marks the selected row by id.
  factory TenantModel.fromRailwireJson(Map<String, dynamic> json) {
    final name = json['state_name'] as String? ?? '';
    return TenantModel(
      id: name,
      code: json['state_code'] as String? ?? '',
      name: name,
      isActive: true,
      appUrl: json['app_url'] as String?,
    );
  }

  TenantEntity toEntity() => TenantEntity(
    id: id,
    code: code,
    name: name,
    nameInLocal: nameInLocal,
    isActive: isActive,
    appUrl: appUrl,
  );
}
