import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/enums/subscriber_enums.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/tab_plan_state.dart';

enum ListPlanStatus { initial, loading, loadingMore, success, error }

enum ActionStatus { idle, loading, success, error }
const _sentinel = Object();
class ChangePlanState extends Equatable {
  final Map<PlanTab, TabPlanState> tabStates;
  final PlanTab activeTab;
  final String? selectedPackageId;
  final ActionStatus actionStatus;
  final String? errorMessage;
  final String? successMessage;
  final String? searchQuery;
  final int? speedFilter;

  const ChangePlanState({
    this.tabStates = const {},
    this.activeTab = PlanTab.all,
    this.selectedPackageId,
    this.actionStatus = ActionStatus.idle,
    this.errorMessage,
    this.successMessage,
    this.searchQuery,
    this.speedFilter,
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
    String? errorMessage,
    String? successMessage,
    String? searchQuery,
    Object? speedFilter = _sentinel,
  }) {
    return ChangePlanState(
      tabStates: tabStates ?? this.tabStates,
      activeTab: activeTab ?? this.activeTab,
      selectedPackageId: selectedPackageId ?? this.selectedPackageId,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
      successMessage: successMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      speedFilter: speedFilter == _sentinel
          ? this.speedFilter
          : speedFilter as int?,
    );
  }

  @override
  List<Object?> get props => [
    tabStates,
    activeTab,
    selectedPackageId,
    actionStatus,
    errorMessage,
    successMessage,
    searchQuery,
    speedFilter,
  ];
}