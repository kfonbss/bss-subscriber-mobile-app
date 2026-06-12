import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/enums/subscriber_enums.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_event.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/tab_plan_state.dart';

class ChangePlanBloc extends Bloc<ChangePlanEvent, ChangePlanState> {
  final ChangePlanRepository repository;
  final size = 10;

  ChangePlanBloc({required this.repository}) : super(const ChangePlanState()) {
    on<LoadPackages>(_onLoadPackages);
    on<LoadMorePackages>(_onLoadMorePackages);
    on<SwitchTab>(_onSwitchTab);
    on<SearchPackages>(_onSearchPackages);
    on<FilterBySpeed>(_onFilterBySpeed);
    on<SelectPackage>(_onSelectPackage);
  }

  bool? _ottForTab(PlanTab tab) {
    switch (tab) {
      case PlanTab.all:
        return null;
      case PlanTab.ottPlans:
        return true;
    }
  }

  Future<void> _onLoadPackages(
    LoadPackages event,
    Emitter<ChangePlanState> emit,
  ) async {
    final tab = event.tab;
    final currentTabStates = Map<PlanTab, TabPlanState>.from(state.tabStates);
    currentTabStates[tab] = const TabPlanState(status: ListPlanStatus.loading);

    emit(state.copyWith(tabStates: currentTabStates));

    try {
      final result = await repository.getPackages(
        GetAllPackagesParams(
          subscriberId: event.subscriberUuid,
          type: 'retail',
          search: tab == PlanTab.all ? state.searchQuery : null,
          speedMbps: tab == PlanTab.all ? state.speedFilter : null,
          ott: _ottForTab(tab),
          page: 0,
          size: size,
        ),
      );

      final updatedTabStates = Map<PlanTab, TabPlanState>.from(state.tabStates);

      result.fold(
        (failure) {
          updatedTabStates[tab] = TabPlanState(
            status: ListPlanStatus.error,
            errorMessage: failure.toString(),
          );
        },
        (packageDetails) {
          final filtered =
              packageDetails.content
                  .where((p) => p.id != event.packageId)
                  .toList();
          updatedTabStates[tab] = TabPlanState(
            status: ListPlanStatus.success,
            packages: filtered,
            hasMore: size < packageDetails.totalElements && filtered.isNotEmpty,
            totalPage: packageDetails.totalElements,
          );
        },
      );

      emit(state.copyWith(tabStates: updatedTabStates));
    } catch (e) {
      final updatedTabStates = Map<PlanTab, TabPlanState>.from(state.tabStates);
      updatedTabStates[tab] = TabPlanState(
        status: ListPlanStatus.error,
        errorMessage: e.toString(),
      );
      emit(state.copyWith(tabStates: updatedTabStates));
    }
  }

  Future<void> _onLoadMorePackages(
    LoadMorePackages event,
    Emitter<ChangePlanState> emit,
  ) async {
    final tab = event.tab;
    final currentTabStates = Map<PlanTab, TabPlanState>.from(state.tabStates);
    currentTabStates[tab] = currentTabStates[tab]!.copyWith(
      status: ListPlanStatus.loadingMore,
    );
    emit(state.copyWith(tabStates: currentTabStates));
    final currentPage = currentTabStates[tab]!.packages.length;
    final totalPage = currentTabStates[tab]!.totalPage;
    try {
      final result = await repository.getPackages(
        GetAllPackagesParams(
          subscriberId: event.subscriberUuid,
          type: 'retail',
          search: tab == PlanTab.all ? state.searchQuery : null,
          speedMbps: tab == PlanTab.all ? state.speedFilter : null,
          ott: _ottForTab(tab),
          page: currentPage + 1,
          size: size,
        ),
      );
      final updatedTabStates = Map<PlanTab, TabPlanState>.from(state.tabStates);
      result.fold(
        (failure) {
          updatedTabStates[tab] = updatedTabStates[tab]!.copyWith(
            status: ListPlanStatus.error,
            errorMessage: failure.toString(),
          );
        },
        (packageDetails) {
          final filtered =
              packageDetails.content
                  .where((p) => p.id != event.packageId)
                  .toList();
          final existingPackage = List<PackageInfoEntity>.from(
            updatedTabStates[tab]!.packages,
          );
          existingPackage.addAll(filtered);
          updatedTabStates[tab] = updatedTabStates[tab]!.copyWith(
            status: ListPlanStatus.success,
            packages: existingPackage,
            hasMore: existingPackage.length < totalPage && filtered.isNotEmpty,
          );
        },
      );
      emit(state.copyWith(tabStates: updatedTabStates));
    } catch (e) {
      final updatedTabStates = Map<PlanTab, TabPlanState>.from(state.tabStates);
      updatedTabStates[tab] = updatedTabStates[tab]!.copyWith(
        status: ListPlanStatus.error,
        errorMessage: e.toString(),
      );
      emit(state.copyWith(tabStates: updatedTabStates));
    }
  }

  void _onSwitchTab(SwitchTab event, Emitter<ChangePlanState> emit) {
    emit(state.copyWith(activeTab: event.tab));

    // Load data for the tab if it hasn't been loaded yet
    final tabState = state.tabStates[event.tab];
    if (tabState == null || tabState.status == ListPlanStatus.initial) {
      add(
        LoadPackages(
          tab: event.tab,
          packageId: event.packageId,
          subscriberUuid: event.subscriberUuid,
        ),
      );
    }
  }

  Future<void> _onSearchPackages(
    SearchPackages event,
    Emitter<ChangePlanState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(
      LoadPackages(
        tab: PlanTab.all,
        packageId: event.packageId,
        subscriberUuid: event.subscriberUuid,
      ),
    );
  }

  Future<void> _onFilterBySpeed(
    FilterBySpeed event,
    Emitter<ChangePlanState> emit,
  ) async {
    emit(state.copyWith(speedFilter: event.speed));
    add(
      LoadPackages(
        tab: PlanTab.all,
        packageId: event.packageId,
        subscriberUuid: event.subscriberUuid,
      ),
    );
  }

  void _onSelectPackage(SelectPackage event, Emitter<ChangePlanState> emit) {
    emit(state.copyWith(selectedPackageId: event.packageId));
  }
}
