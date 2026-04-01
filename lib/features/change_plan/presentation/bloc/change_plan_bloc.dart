import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/enums/subscriber_enums.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/get_all_packages_parms.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_event.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/tab_plan_state.dart';

class ChangePlanBloc extends Bloc<ChangePlanEvent, ChangePlanState> {
  final ChangePlanRepository repository;

  ChangePlanBloc({required this.repository}) : super(const ChangePlanState()) {
    on<LoadPackages>(_onLoadPackages);
    // on<LoadMorePackages>(_onLoadMorePackages);
    on<SwitchTab>(_onSwitchTab);
    on<SearchPackages>(_onSearchPackages);
    on<FilterBySpeed>(_onFilterBySpeed);
    on<SelectPackage>(_onSelectPackage);
    on<ChangePlan>(_onChangePlan);
    on<RechargeChangePlan>(_onRechargeChangePlan);
    on<FetchRechargePaymentStatus>(_onFetchRechargePaymentStatus);
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

    final result = await repository.getPackages(
      GetAllPackagesParams(
        subscriberId: event.subscriberUuid,
        type: 'retail',
        search: tab == PlanTab.all ? state.searchQuery : null,
        speedMbps: tab == PlanTab.all ? state.speedFilter : null,
        ott: _ottForTab(tab),
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
      (packages) {
        final filtered =
            packages.where((p) => p.packageId != event.packageId).toList();
        updatedTabStates[tab] = TabPlanState(
          status: ListPlanStatus.success,
          packages: filtered,
          hasMore: false,
        );
      },
    );

    emit(state.copyWith(tabStates: updatedTabStates));
  }
  //   // No pagination in the new API

  // Future<void> _onLoadMorePackages(
  //   LoadMorePackages event,
  //   Emitter<ChangePlanState> emit,
  // ) async {
  //   return;
  // }

  void _onSwitchTab(SwitchTab event, Emitter<ChangePlanState> emit) {
    emit(state.copyWith(activeTab: event.tab));

    // Load data for the tab if it hasn't been loaded yet
    final tabState = state.tabStates[event.tab];
    if (tabState == null || tabState.status == ListPlanStatus.initial) {
      add(LoadPackages(
        tab: event.tab,
        packageId: event.packageId,
        subscriberUuid: event.subscriberUuid,
      ));
    }
  }

  Future<void> _onSearchPackages(
    SearchPackages event,
    Emitter<ChangePlanState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    add(LoadPackages(
      tab: PlanTab.all,
      packageId: event.packageId,
      subscriberUuid: event.subscriberUuid,
    ));
  }

  Future<void> _onFilterBySpeed(
    FilterBySpeed event,
    Emitter<ChangePlanState> emit,
  ) async {
    emit(state.copyWith(speedFilter: event.speed));
    add(LoadPackages(
      tab: PlanTab.all,
      packageId: event.packageId,
      subscriberUuid: event.subscriberUuid,
    ));
  }

  void _onSelectPackage(SelectPackage event, Emitter<ChangePlanState> emit) {
    emit(state.copyWith(selectedPackageId: event.packageId));
  }

  Future<void> _onChangePlan(
    ChangePlan event,
    Emitter<ChangePlanState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ActionStatus.loading));

    final result = await repository.changePlan(
      event.subscriberUuid,
      event.params,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: ActionStatus.error,
          errorMessage: failure.toString(),
        ),
      ),
      (_) => emit(state.copyWith(actionStatus: ActionStatus.success)),
    );
  }

  Future<void> _onRechargeChangePlan(
    RechargeChangePlan event,
    Emitter<ChangePlanState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ActionStatus.loading));

    final result = await repository.rechargeChangePlan(event.params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          actionStatus: ActionStatus.error,
          errorMessage: failure.toString(),
        ),
      ),
      (data) => emit(
        state.copyWith(
          actionStatus: ActionStatus.success,
          redirectEntity: data.redirect,
          orderId: data.orderId,
        ),
      ),
    );
  }

  Future<void> _onFetchRechargePaymentStatus(
    FetchRechargePaymentStatus event,
    Emitter<ChangePlanState> emit,
  ) async {
    emit(state.copyWith(paymentStatus: PaymentStatus.loading));

    final result = await repository.getRechargePaymentStatus(event.orderId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          paymentStatus: PaymentStatus.failed,
          errorMessage: failure.toString(),
        ),
      ),
      (entity) => emit(
        state.copyWith(
          paymentStatus: PaymentStatus.success,
          paymentStatusEntity: entity,
        ),
      ),
    );
  }
}
