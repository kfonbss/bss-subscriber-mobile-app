import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/package_entity_mapper.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/seasonal_plan_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/seasonal_plan_event.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/seasonal_plan_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/seasonal_plan_tile.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/recharge_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/subscriber_search_field.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SeasonalPlanPage extends StatelessWidget {
  final String subscriberUuid;
  final String subscriberName;
  final String currentPackageId;
  final bool isUpgradeFlow;

  const SeasonalPlanPage({
    super.key,
    required this.subscriberUuid,
    required this.subscriberName,
    required this.currentPackageId,
    this.isUpgradeFlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = SeasonalPlanBloc(repository: sl<ChangePlanRepository>());

        bloc.add(
          LoadPackageTab(
            subscriberId: subscriberUuid,
            currentPackageId: currentPackageId,
          ),
        );

        return bloc;
      },
      child: _SeasonalPlanView(
        subscriberUuid: subscriberUuid,
        subscriberName: subscriberName,
        currentPackageId: currentPackageId,
      ),
    );
  }
}

class _SeasonalPlanView extends StatefulWidget {
  final String subscriberUuid;
  final String subscriberName;
  final String currentPackageId;

  const _SeasonalPlanView({
    required this.subscriberUuid,
    required this.subscriberName,
    required this.currentPackageId,
  });

  @override
  State<_SeasonalPlanView> createState() => _SeasonalPlanViewState();
}

class _SeasonalPlanViewState extends State<_SeasonalPlanView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildPackageTabs(BuildContext context, SeasonalPlanState state) {
    final packageTab = state.packageTab;

    if (packageTab == null) {
      return const SizedBox.shrink();
    }

    final tabs = <PackageTabType>[];

    if (packageTab.changePackage?.eligible == true) {
      tabs.add(PackageTabType.changePackage);
    }
    if (packageTab.upgrade?.eligible == true) {
      tabs.add(PackageTabType.upgrade);
    }
    if (packageTab.standalone?.eligible == true) {
      tabs.add(PackageTabType.standalone);
    }
    if (packageTab.addon?.eligible == true) {
      tabs.add(PackageTabType.addon);
    }

    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColor.kSecondaryBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (context, index) => SizedBox(width: 6.w),
        itemBuilder: (context, index) {
          final t = tabs[index];
          final active = state.selectedTab == t;

          final serviceTypes = state.targetKindsForTab(t);

          return GestureDetector(
            onTap: () {
              final bloc = context.read<SeasonalPlanBloc>();

              if (serviceTypes.isNotEmpty) {
                _showServiceTypesBottomSheet(
                  context,
                  bloc: bloc,
                  tab: t,
                  serviceTypes: serviceTypes,
                  selectedServiceType:
                      bloc.state.selectedTargetKind ?? serviceTypes.first,
                );
                return;
              }
              bloc.add(
                SelectPackageTab(
                  tab: t,
                  subscriberId: widget.subscriberUuid,
                  packageId: widget.currentPackageId,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    active ? AppColor.kTabActiveBackground : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border:
                    active ? Border.all(color: AppColor.kDaysLeftYellow) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.displayName,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                      color:
                          active
                              ? AppColor.kTextSecondaryDark
                              : AppColor.kTextSecondary,
                      fontFamily: 'General Sans',
                    ),
                  ),

                  if (serviceTypes.isNotEmpty) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color:
                          active
                              ? AppColor.kTextSecondaryDark
                              : AppColor.kTextSecondary,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showServiceTypesBottomSheet(
    BuildContext context, {
    required SeasonalPlanBloc bloc,
    required PackageTabType tab,
    required List<String> serviceTypes,
    String? selectedServiceType,
  }) {
    showAppModalBottomSheet(
      context: context,
      builder: (modalContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.bssSubL10n.selectServiceType,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.kTextSecondaryDark,
                      fontFamily: 'General Sans',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      Navigator.pop(modalContext);
                    },
                  ),
                ],
              ),

              Divider(height: 1.h),

              SizedBox(height: 8.h),

              // Service Types
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: serviceTypes.length,
                  itemBuilder: (context, index) {
                    final item = serviceTypes[index];

                    final isSelected = item == selectedServiceType;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,

                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isSelected
                                  ? AppColor.kTextSecondaryDark
                                  : AppColor.kTextSecondary,
                          fontFamily: 'General Sans',
                        ),
                      ),

                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColor.kTextSecondaryDark,
                              )
                              : null,

                      onTap: () {
                        bloc.add(
                          SelectPackageTab(
                            tab: tab,
                            subscriberId: widget.subscriberUuid,
                            packageId: widget.currentPackageId,
                          ),
                        );

                        bloc.add(
                          SelectTargetKind(
                            targetKind: item,
                            subscriberId: widget.subscriberUuid,
                            packageId: widget.currentPackageId,
                          ),
                        );

                        Navigator.pop(modalContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<SeasonalPlanBloc>().add(
        LoadMoreSeasonalPackages(
          currentPackageId: widget.currentPackageId,
          subscriberId: widget.subscriberUuid,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      title: l10n.changePlan,

      onBackPressed: () {
        Navigator.pop(context);
      },

      body: Stack(
        children: [
          Column(
            children: [
              // ---------------------------------------------------------------
              // SEARCH
              // ---------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SubscriberSearchField(
                  controller: _searchController,
                  hintText: l10n.searchPackage,
                  onChanged: (query) {
                    context.read<SeasonalPlanBloc>().add(
                      SearchSeasonalPackages(
                        query: query,
                        currentPackageId: widget.currentPackageId,
                        subscriberId: widget.subscriberUuid,
                      ),
                    );
                  },
                  // onFilterPressed:
                  // _showSeasonalFilters,
                  // filterIconColor:
                  // AppColor.kSecondaryColor,
                ),
              ),

              SizedBox(height: 16.h),

              // ---------------------------------------------------------------
              // PACKAGE TABS + TARGET KIND
              // ---------------------------------------------------------------
              BlocBuilder<SeasonalPlanBloc, SeasonalPlanState>(
                buildWhen: (previous, current) {
                  return previous.packageTab != current.packageTab ||
                      previous.selectedTab != current.selectedTab ||
                      previous.selectedTargetKind != current.selectedTargetKind;
                },
                builder: (context, state) {
                  return _buildPackageTabs(context, state);
                },
              ),

              SizedBox(height: 12.h),

              // ---------------------------------------------------------------
              // PACKAGE LIST
              // ---------------------------------------------------------------
              Expanded(
                child: BlocBuilder<SeasonalPlanBloc, SeasonalPlanState>(
                  builder: (context, state) {
                    // ---------------------------------------------------------
                    // INITIAL LOADING
                    // ---------------------------------------------------------

                    if (state.status == SeasonalPlanStatus.loading) {
                      return const ListShimmer();
                    }

                    // ---------------------------------------------------------
                    // ERROR
                    // ---------------------------------------------------------

                    if (state.status == SeasonalPlanStatus.error) {
                      return RetryWidget(
                        errorMessage:
                            state.errorMessage ?? l10n.somethingWentWrong,
                        onRetry: () {
                          context.read<SeasonalPlanBloc>().add(
                            LoadSeasonalPackages(
                              subscriberId: widget.subscriberUuid,
                              currentPackageId: widget.currentPackageId,
                            ),
                          );
                        },
                      );
                    }

                    // ---------------------------------------------------------
                    // NO DATA
                    // ---------------------------------------------------------

                    if (state.status == SeasonalPlanStatus.success &&
                        state.packages.isEmpty) {
                      return NoDataFound(
                        errorMessage: l10n.noPackagesAvailable,
                      );
                    }

                    // ---------------------------------------------------------
                    // LIST
                    // ---------------------------------------------------------

                    return ListView.separated(
                      controller: _scrollController,

                      padding: EdgeInsets.only(
                        left: 16,
                        right: 10,
                        bottom: MediaQuery.viewPaddingOf(context).bottom + 90,
                      ),

                      itemCount:
                          state.packages.length +
                          (state.status == SeasonalPlanStatus.loadingMore
                              ? 1
                              : 0),

                      itemBuilder: (context, index) {
                        // -----------------------------------------------------
                        // LOADING MORE
                        // -----------------------------------------------------

                        if (index >= state.packages.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: AppShimmer(
                              child: ShimmerBox(
                                width: double.infinity,
                                height: 80.h,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }

                        // -----------------------------------------------------
                        // PACKAGE
                        // -----------------------------------------------------

                        final package = state.packages[index];

                        return SeasonalPlanTile(
                          package: package,

                          isSelected:
                              state.selectedPackage != null &&
                              state.selectedPackage!.packageId ==
                                  package.packageId,

                          onTap: () {
                            context.read<SeasonalPlanBloc>().add(
                              SelectSeasonalPackage(package),
                            );
                          },
                        );
                      },

                      separatorBuilder: (context, index) {
                        return SizedBox(height: 10.h);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,

              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.viewPaddingOf(context).bottom + 16,
              ),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.2, 0.4],
                ),
              ),

              child: BlocBuilder<SeasonalPlanBloc, SeasonalPlanState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed:
                        state.selectedPackage == null
                            ? null
                            : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder:
                                      (_) => BlocProvider.value(
                                        value: context.read<SeasonalPlanBloc>(),
                                        child: RechargePage(
                                          isChangePlan: true,
                                          package:
                                              state.selectedPackage!
                                                  .toPackageInfoEntity(),
                                        ),
                                      ),
                                ),
                              );
                            },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),

                    child: Text(
                      l10n.changePackage,

                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.3.h,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
