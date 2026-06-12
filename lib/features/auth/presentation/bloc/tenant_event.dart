import 'package:equatable/equatable.dart';
import '../../domain/entity/tenant_entity.dart';

abstract class TenantEvent extends Equatable {
  const TenantEvent();
  @override
  List<Object?> get props => [];
}

class LoadTenants extends TenantEvent {
  const LoadTenants();
}

class SearchTenants extends TenantEvent {
  final String query;
  const SearchTenants({required this.query});
  @override
  List<Object?> get props => [query];
}

class SelectTenant extends TenantEvent {
  final TenantEntity tenant;
  const SelectTenant({required this.tenant});
  @override
  List<Object?> get props => [tenant];
}