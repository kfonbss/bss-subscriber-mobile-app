import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/enums/subscriber_enums.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/tab_plan_state.dart';

enum ListPlanStatus { initial, loading, loadingMore, success, error }

enum ActionStatus { idle, loading, success, error }

enum PaymentStatus { idle, loading, success, failed, cancelled }

const _sentinel = Object();

class ChangePlanState extends Equatable {
  final Map<PlanTab, TabPlanState> tabStates;
  final PlanTab activeTab;
  final String? selectedPackageId;
  final ActionStatus actionStatus;
  final PaymentStatus paymentStatus;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;
  final int? speedFilter;
  final RechargeChangePlanRedirectEntity? redirectEntity;
  final String? orderId;
  final RechargePaymentStatusEntity? paymentStatusEntity;

  const ChangePlanState({
    this.tabStates = const {},
    this.activeTab = PlanTab.all,
    this.selectedPackageId,
    this.actionStatus = ActionStatus.idle,
    this.paymentStatus = PaymentStatus.idle,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
    this.speedFilter,
    this.redirectEntity,
    this.orderId,
    this.paymentStatusEntity,
  });

  TabPlanState get activeTabState =>
      tabStates[activeTab] ?? const TabPlanState();

  PackageEntity? get selectedPackage {
    if (selectedPackageId == null) return null;
    // Search across all tabs for the selected package
    for (final tabState in tabStates.values) {
      try {
        return tabState.packages.firstWhere(
          (p) => p.packageId == selectedPackageId,
        );
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  ChangePlanState copyWith({
    Map<PlanTab, TabPlanState>? tabStates,
    PlanTab? activeTab,
    String? selectedPackageId,
    ActionStatus? actionStatus,
    PaymentStatus? paymentStatus,
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    Object? speedFilter = _sentinel,
    RechargeChangePlanRedirectEntity? redirectEntity,
    String? orderId,
    RechargePaymentStatusEntity? paymentStatusEntity,
  }) {
    return ChangePlanState(
      tabStates: tabStates ?? this.tabStates,
      activeTab: activeTab ?? this.activeTab,
      selectedPackageId: selectedPackageId ?? this.selectedPackageId,
      actionStatus: actionStatus ?? this.actionStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      speedFilter:
          speedFilter == _sentinel ? this.speedFilter : speedFilter as int?,
      redirectEntity: redirectEntity ?? this.redirectEntity,
      orderId: orderId ?? this.orderId,
      paymentStatusEntity: paymentStatusEntity ?? this.paymentStatusEntity,
    );
  }

  @override
  List<Object?> get props => [
    tabStates,
    activeTab,
    selectedPackageId,
    actionStatus,
    paymentStatus,
    errorMessage,
    successMessage,
    searchQuery,
    speedFilter,
    redirectEntity,
    orderId,
    paymentStatusEntity,
  ];
}
