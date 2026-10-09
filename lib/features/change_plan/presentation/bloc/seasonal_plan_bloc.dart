import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/package_tab_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/params/subscriber_discount_request_params.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';

import 'seasonal_plan_event.dart';
import 'seasonal_plan_state.dart';

class SeasonalPlanBloc extends Bloc<SeasonalPlanEvent, SeasonalPlanState> {
  final ChangePlanRepository repository;

  SeasonalPlanBloc({required this.repository})
    : super(const SeasonalPlanState()) {
    // Tabs
    on<LoadPackageTab>(_onLoadPackageTab);
    on<SelectPackageTab>(_onSelectPackageTab);
    on<SelectTargetKind>(_onSelectTargetKind);

    // Packages
    on<LoadSeasonalPackages>(_onLoadSeasonalPackages);
    on<LoadMoreSeasonalPackages>(_onLoadMoreSeasonalPackages);
    on<SearchSeasonalPackages>(_onSearchSeasonalPackages);
    on<ApplySeasonalPlanFilters>(_onApplySeasonalPlanFilters);
    on<SelectSeasonalPackage>(_onSelectSeasonalPackage);

    // Discount
    on<FetchSeasonalDiscount>(_onFetchSeasonalDiscount);
  }

  // ============================================================
  // SEARCH HELPER
  // ============================================================

  String? _apiSearch(String? value) {
    final query = value?.trim() ?? '';

    return query.isEmpty ? null : query;
  }

  // ============================================================
  // LOAD PACKAGE TABS
  // ============================================================

  Future<void> _onLoadPackageTab(
    LoadPackageTab event,
    Emitter<SeasonalPlanState> emit,
  ) async {
    emit(
      state.copyWith(status: SeasonalPlanStatus.loading, errorMessage: null),
    );
    final result = await repository.getPackageTabs(
      subscriberId: event.subscriberId,
      packageId: event.currentPackageId,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(packageTab: null, errorMessage: failure.message));
      },
      (tab) {
        final availableTabs = _getAvailableTabs(tab);

        if (availableTabs.isEmpty) {
          emit(
            state.copyWith(
              packageTab: tab,
              selectedTab: null,
              selectedTargetKind: null,
            ),
          );

          return;
        }

        // First available tab
        final firstTab = availableTabs.first;

        // Get eligibility for THIS tab
        final eligibility = _getEligibility(tab, firstTab);

        // Target kinds belonging to THIS tab
        final targetKinds = eligibility?.serviceTypes ?? const <String>[];

        emit(
          state.copyWith(
            packageTab: tab,
            selectedTab: firstTab,
            selectedTargetKind:
                targetKinds.isNotEmpty ? targetKinds.first : null,
            errorMessage: null,
          ),
        );

        add(
          LoadSeasonalPackages(
            subscriberId: event.subscriberId,
            currentPackageId: event.currentPackageId,
            reset: true,
          ),
        );
      },
    );
  }

  // ============================================================
  // SELECT PACKAGE TAB
  // ============================================================

  Future<void> _onSelectPackageTab(
    SelectPackageTab event,
    Emitter<SeasonalPlanState> emit,
  ) async {
    final eligibility = _getEligibility(state.packageTab, event.tab);

    final targetKinds = eligibility?.serviceTypes ?? const <String>[];

    /*
     * Every time the tab changes:
     *
     * 1. Change selectedTab
     * 2. Get serviceTypes for THAT tab
     * 3. Select first target kind of THAT tab
     * 4. Reload packages
     */

    final selectedTargetKind =
        targetKinds.isNotEmpty ? targetKinds.first : null;

    emit(
      state.copyWith(
        selectedTab: event.tab,
        selectedTargetKind: selectedTargetKind,
        selectedPackage: null,
      ),
    );

    add(
      LoadSeasonalPackages(
        subscriberId: event.subscriberId,
        currentPackageId: event.packageId,
        reset: true,
      ),
    );
  }

  // ============================================================
  // SELECT TARGET KIND
  // ============================================================

  Future<void> _onSelectTargetKind(
    SelectTargetKind event,
    Emitter<SeasonalPlanState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedTargetKind: event.targetKind,
        selectedPackage: null,
      ),
    );

    add(
      LoadSeasonalPackages(
        subscriberId: event.subscriberId,
        currentPackageId: event.packageId,
        reset: true,
      ),
    );
  }

  // ============================================================
  // LOAD PACKAGES
  // ============================================================

  Future<void> _onLoadSeasonalPackages(
    LoadSeasonalPackages event,
    Emitter<SeasonalPlanState> emit,
  ) async {
    final shouldReset = event.reset;

    emit(
      state.copyWith(
        status: SeasonalPlanStatus.loading,
        errorMessage: null,
        packages: shouldReset ? const [] : state.packages,
        currentPage: shouldReset ? 0 : state.currentPage,
        totalPages: shouldReset ? 0 : state.totalPages,
        hasMore: shouldReset ? true : state.hasMore,
      ),
    );

    final result = await repository.getSeasonalPackages(
      page: 0,
      size: 10,

      subscriberId: event.subscriberId,
      packageId: event.currentPackageId,

      // IMPORTANT
      type: state.selectedTab?.apiValue,

      // IMPORTANT
      targetKind: state.selectedTargetKind,

      subscriptionType: state.subscriptionTypeFilter,

      packageType: state.packageTypeFilter,

      search: _apiSearch(event.search ?? state.searchQuery),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SeasonalPlanStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (pageData) {
        final visible = _packagesMinusCurrent(
          pageData.content,
          event.currentPackageId,
        );

        emit(
          state.copyWith(
            status: SeasonalPlanStatus.success,
            packages: visible,
            currentPage: pageData.number,
            totalPages: pageData.totalPages,
            hasMore: !pageData.last,

            selectedPackage:
                visible.any(
                      (e) =>
                          state.selectedPackage != null &&
                          e.packageId == state.selectedPackage!.packageId,
                    )
                    ? state.selectedPackage!
                    : null,
          ),
        );
      },
    );
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Future<void> _onLoadMoreSeasonalPackages(
    LoadMoreSeasonalPackages event,
    Emitter<SeasonalPlanState> emit,
  ) async {
    if (!state.hasMore || state.status == SeasonalPlanStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: SeasonalPlanStatus.loadingMore));

    final nextPage = state.currentPage + 1;

    final result = await repository.getSeasonalPackages(
      subscriberId: event.subscriberId,
      packageId: event.currentPackageId,

      type: state.selectedTab?.apiValue,

      targetKind: state.selectedTargetKind,

      page: nextPage,
      size: 10,

      subscriptionType: state.subscriptionTypeFilter,

      packageType: state.packageTypeFilter,

      search: _apiSearch(state.searchQuery),
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: SeasonalPlanStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      (pageData) {
        final newItems = _packagesMinusCurrent(
          pageData.content,
          event.currentPackageId,
        );

        final merged = [...state.packages, ...newItems];

        emit(
          state.copyWith(
            status: SeasonalPlanStatus.success,
            packages: merged,
            currentPage: pageData.number,
            totalPages: pageData.totalPages,
            hasMore: !pageData.last,
          ),
        );
      },
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _onSearchSeasonalPackages(
    SearchSeasonalPackages event,
    Emitter<SeasonalPlanState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));

    add(
      LoadSeasonalPackages(
        subscriberId: event.subscriberId,
        currentPackageId: event.currentPackageId,
        reset: true,
        search: event.query,
      ),
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  Future<void> _onApplySeasonalPlanFilters(
    ApplySeasonalPlanFilters event,
    Emitter<SeasonalPlanState> emit,
  ) async {
    emit(
      state.copyWith(
        subscriptionTypeFilter: event.subscriptionType,
        packageTypeFilter: event.packageType,
      ),
    );

    add(
      LoadSeasonalPackages(
        subscriberId: event.subscriberId,
        currentPackageId: event.currentPackageId,
        reset: true,
      ),
    );
  }

  // ============================================================
  // SELECT PACKAGE
  // ============================================================

  void _onSelectSeasonalPackage(
    SelectSeasonalPackage event,
    Emitter<SeasonalPlanState> emit,
  ) {
    emit(state.copyWith(selectedPackage: event.selectedPackage));
  }

  // ============================================================
  // DISCOUNT
  // ============================================================

  Future<void> _onFetchSeasonalDiscount(
    FetchSeasonalDiscount event,
    Emitter<SeasonalPlanState> emit,
  ) async {
    emit(
      state.copyWith(
        isDiscountLoading: true,
        discountErrorMessage: null,
        discountDetail: null,
      ),
    );

    final result = await repository.getSubscriberDiscounts([
      SubscriberDiscountRequestParams(
        subscriberId: event.subscriberUuid,
        packageId: event.packageId,
        seasonId: event.seasonId,
        paymentMode: null,
        referral: false,
        referralCode: null,
      ),
    ]);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isDiscountLoading: false,
            discountErrorMessage: failure.message,
            discountDetail: null,
          ),
        );
      },
      (discounts) {
        emit(
          state.copyWith(
            isDiscountLoading: false,
            discountErrorMessage: null,
            discountDetail: discounts.isNotEmpty ? discounts.first : null,
          ),
        );
      },
    );
  }

  // ============================================================
  // AVAILABLE TABS
  // ============================================================

  List<PackageTabType> _getAvailableTabs(PackageTabEntity tab) {
    final result = <PackageTabType>[];

    if (tab.changePackage?.eligible == true) {
      result.add(PackageTabType.changePackage);
    }

    if (tab.upgrade?.eligible == true) {
      result.add(PackageTabType.upgrade);
    }

    if (tab.standalone?.eligible == true) {
      result.add(PackageTabType.standalone);
    }

    if (tab.addon?.eligible == true) {
      result.add(PackageTabType.addon);
    }

    return result;
  }

  // ============================================================
  // GET ELIGIBILITY
  // ============================================================

  EligibilityEntity? _getEligibility(
    PackageTabEntity? tab,
    PackageTabType type,
  ) {
    if (tab == null) {
      return null;
    }

    switch (type) {
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
  // REMOVE CURRENT PACKAGE
  // ============================================================

  List<PackageEntity> _packagesMinusCurrent(
    List<PackageEntity> packages,
    String currentPackageId,
  ) {
    return packages.where((e) => e.packageId != currentPackageId).toList();
  }
}
