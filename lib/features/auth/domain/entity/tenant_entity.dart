import 'package:equatable/equatable.dart';

class TenantEntity extends Equatable {
  final String  id;
  final String  code;
  final String  name;
  final String? nameInLocal;
  final bool    isActive;

  const TenantEntity({
    required this.id,
    required this.code,
    required this.name,
    this.nameInLocal,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, code, name, nameInLocal, isActive];
}