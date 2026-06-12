import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/tenant_repository.dart';
import 'tenant_event.dart';
import 'tenant_state.dart';

class TenantBloc extends Bloc<TenantEvent, TenantState> {
  final TenantRepository _repository;

  TenantBloc(this._repository) : super(const TenantState()) {
    on<LoadTenants>(_onLoad);
    on<SearchTenants>(_onSearch);
    on<SelectTenant>(_onSelect);
  }

  Future<void> _onLoad(
      LoadTenants event,
      Emitter<TenantState> emit,
      ) async {
    emit(state.copyWith(status: TenantLoadStatus.loading));

    final result = await _repository.getTenants();

    result.fold(
          (failure) => emit(state.copyWith(
        status:       TenantLoadStatus.error,
        errorMessage: failure.message,
      )),
          (list) => emit(state.copyWith(
        status:          TenantLoadStatus.loaded,
        allTenants:      list,
        filteredTenants: list,
      )),
    );
  }

  void _onSearch(
      SearchTenants event,
      Emitter<TenantState> emit,
      ) {
    final q = event.query.toLowerCase();
    final filtered = q.isEmpty
        ? state.allTenants
        : state.allTenants
        .where((e) =>
    e.name.toLowerCase().contains(q) ||
        e.code.toLowerCase().contains(q))
        .toList();

    emit(state.copyWith(
      filteredTenants: filtered,
      searchQuery:     event.query,
    ));
  }

  void _onSelect(
      SelectTenant event,
      Emitter<TenantState> emit,
      ) {
    emit(state.copyWith(selectedTenant: event.tenant));
  }
}