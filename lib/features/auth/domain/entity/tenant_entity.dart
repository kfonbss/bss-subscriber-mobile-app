import 'package:equatable/equatable.dart';

class TenantEntity extends Equatable {
  final String id;
  final String code;
  final String name;
  final String? nameInLocal;
  final bool isActive;

  /// RailWire only: the state's URL from `state_list`.
  final String? appUrl;

  const TenantEntity({
    required this.id,
    required this.code,
    required this.name,
    this.nameInLocal,
    required this.isActive,
    this.appUrl,
  });

  @override
  List<Object?> get props => [id, code, name, nameInLocal, isActive, appUrl];
}
