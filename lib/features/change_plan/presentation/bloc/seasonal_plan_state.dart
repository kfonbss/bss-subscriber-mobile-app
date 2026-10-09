import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_tab_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/subscriber_discount_entity.dart';

import 'seasonal_plan_event.dart';

enum SeasonalPlanStatus { initial, loading, loadingMore, success, error }

enum SeasonalActionStatus { idle, loading, success, error }

const _sentinel = Object();

class SeasonalPlanState extends Equatable {
  // ============================================================
  // PACKAGE LIST
  // ============================================================

  final SeasonalPlanStatus status;

  final List<PackageEntity> packages;

  final String? errorMessage;

  final PackageEntity? selectedPackage;

  final String searchQuery;

  final String? subscriptionTypeFilter;

  final String? packageTypeFilter;

  final int currentPage;

  final int totalPages;

  final bool hasMore;

  // ============================================================
  // PACKAGE TAB
  // ============================================================

  final PackageTabEntity? packageTab;

  final PackageTabType? selectedTab;

  final String? selectedTargetKind;

  // ============================================================
  // DISCOUNT
  // ============================================================

  final bool isDiscountLoading;

  final SubscriberDiscountEntity? discountDetail;

  final String? discountErrorMessage;

  // ============================================================
  // ACTION
  // ============================================================

  final SeasonalActionStatus actionStatus;

  const SeasonalPlanState({
    this.status = SeasonalPlanStatus.initial,
    this.packages = const [],
    this.errorMessage,
    this.selectedPackage,
    this.searchQuery = '',
    this.subscriptionTypeFilter,
    this.packageTypeFilter,
    this.currentPage = 0,
    this.totalPages = 0,
    this.hasMore = true,
    this.packageTab,
    this.selectedTab,
    this.selectedTargetKind,
    this.isDiscountLoading = false,
    this.discountDetail,
    this.discountErrorMessage,
    this.actionStatus = SeasonalActionStatus.idle,
  });

  // ============================================================
  // SELECTED ELIGIBILITY
  // ============================================================
  List<String> targetKindsForTab(PackageTabType type) {
    final tab = packageTab;

    if (tab == null) {
      return const [];
    }

    switch (type) {
      case PackageTabType.addon:
        return tab.addon?.serviceTypes ?? const [];

      case PackageTabType.standalone:
        return tab.standalone?.serviceTypes ?? const [];

      case PackageTabType.changePackage:
        return tab.changePackage?.serviceTypes ?? const [];

      case PackageTabType.upgrade:
        return tab.upgrade?.serviceTypes ?? const [];
    }
  }

  EligibilityEntity? get selectedEligibility {
    final tab = packageTab;
    final selected = selectedTab;

    if (tab == null || selected == null) {
      return null;
    }

    switch (selected) {
      case PackageTabType.addon:
        return tab.addon;

      case PackageTabType.standalone:
        return tab.standalone;

      case PackageTabType.changePackage:
        return tab.changePackage;

      case PackageTabType.upgrade:
        return tab.upgrade;
    }
  }

  // ============================================================
  // AVAILABLE TARGET KINDS
  // ============================================================

  List<String> get selectedTargetKinds {
    return selectedEligibility?.serviceTypes ?? const [];
  }

  bool get showTargetKindDropdown {
    return selectedTargetKinds.isNotEmpty;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  SeasonalPlanState copyWith({
    SeasonalPlanStatus? status,
    List<PackageEntity>? packages,
    Object? errorMessage = _sentinel,
    PackageEntity? selectedPackage,
    String? searchQuery,
    Object? subscriptionTypeFilter = _sentinel,
    Object? packageTypeFilter = _sentinel,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    Object? packageTab = _sentinel,
    Object? selectedTab = _sentinel,
    Object? selectedTargetKind = _sentinel,
    bool? isDiscountLoading,
    Object? discountDetail = _sentinel,
    Object? discountErrorMessage = _sentinel,
    SeasonalActionStatus? actionStatus,
  }) {
    return SeasonalPlanState(
      status: status ?? this.status,
      packages: packages ?? this.packages,

      errorMessage:
          identical(errorMessage, _sentinel)
              ? this.errorMessage
              : errorMessage as String?,

      selectedPackage: selectedPackage ?? this.selectedPackage,

      searchQuery: searchQuery ?? this.searchQuery,

      subscriptionTypeFilter:
          identical(subscriptionTypeFilter, _sentinel)
              ? this.subscriptionTypeFilter
              : subscriptionTypeFilter as String?,

      packageTypeFilter:
          identical(packageTypeFilter, _sentinel)
              ? this.packageTypeFilter
              : packageTypeFilter as String?,

      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,

      packageTab:
          identical(packageTab, _sentinel)
              ? this.packageTab
              : packageTab as PackageTabEntity?,

      selectedTab:
          identical(selectedTab, _sentinel)
              ? this.selectedTab
              : selectedTab as PackageTabType?,

      selectedTargetKind:
          identical(selectedTargetKind, _sentinel)
              ? this.selectedTargetKind
              : selectedTargetKind as String?,

      isDiscountLoading: isDiscountLoading ?? this.isDiscountLoading,

      discountDetail:
          identical(discountDetail, _sentinel)
              ? this.discountDetail
              : discountDetail as SubscriberDiscountEntity?,

      discountErrorMessage:
          identical(discountErrorMessage, _sentinel)
              ? this.discountErrorMessage
              : discountErrorMessage as String?,

      actionStatus: actionStatus ?? this.actionStatus,
    );
  }

  @override
  List<Object?> get props => [
    status,
    packages,
    errorMessage,
    selectedPackage,
    searchQuery,
    subscriptionTypeFilter,
    packageTypeFilter,
    currentPage,
    totalPages,
    hasMore,
    packageTab,
    selectedTab,
    selectedTargetKind,
    isDiscountLoading,
    discountDetail,
    discountErrorMessage,
    actionStatus,
  ];
}
