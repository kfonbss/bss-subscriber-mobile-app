import 'package:equatable/equatable.dart';
import '../../domain/entity/tenant_entity.dart';

enum TenantLoadStatus { initial, loading, loaded, error }

class TenantState extends Equatable {
  final TenantLoadStatus    status;
  final List<TenantEntity>  allTenants;
  final List<TenantEntity>  filteredTenants;
  final TenantEntity?       selectedTenant;
  final String?             errorMessage;
  final String              searchQuery;

  const TenantState({
    this.status          = TenantLoadStatus.initial,
    this.allTenants      = const [],
    this.filteredTenants = const [],
    this.selectedTenant,
    this.errorMessage,
    this.searchQuery     = '',
  });

  bool get isLoading  => status == TenantLoadStatus.loading;
  bool get isLoaded   => status == TenantLoadStatus.loaded;
  bool get hasError   => status == TenantLoadStatus.error;
  bool get canContinue => selectedTenant != null;

  TenantState copyWith({
    TenantLoadStatus?   status,
    List<TenantEntity>? allTenants,
    List<TenantEntity>? filteredTenants,
    TenantEntity?       selectedTenant,
    String?             errorMessage,
    String?             searchQuery,
  }) =>
      TenantState(
        status:          status          ?? this.status,
        allTenants:      allTenants      ?? this.allTenants,
        filteredTenants: filteredTenants ?? this.filteredTenants,
        selectedTenant:  selectedTenant  ?? this.selectedTenant,
        errorMessage:    errorMessage    ?? this.errorMessage,
        searchQuery:     searchQuery     ?? this.searchQuery,
      );

  @override
  List<Object?> get props => [
    status, allTenants, filteredTenants,
    selectedTenant, errorMessage, searchQuery,
  ];
}