import 'package:kfon_subscriber/core/constant/constant_colors.dart';

import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
import 'package:kfon_subscriber/features/change_plan/domain/enums/subscriber_enums.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_event.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/tab_plan_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/plan_tile.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/speed_filter_sheet.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/recharge_page.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/no_data_found.dart';
import 'package:kfon_subscriber/presentation/ui_component/retry_widget.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/list_shimmers.dart';

import 'package:kfon_subscriber/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

class ChangePlanPage extends StatelessWidget {
  final String subscriberUuid;
  final String currentPackageId;

  const ChangePlanPage({
    super.key,
    required this.subscriberUuid,
    required this.currentPackageId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ChangePlanBloc(repository: sl<ChangePlanRepository>())
            ..add(LoadPackages(tab: PlanTab.all, packageId: currentPackageId)),
      child: _ChangePlanView(
        subscriberUuid: subscriberUuid,
        currentPackageId: currentPackageId,
      ),
    );
  }
}

class _ChangePlanView extends StatefulWidget {
  final String subscriberUuid;
  final String currentPackageId;

  const _ChangePlanView({
    required this.subscriberUuid,
    required this.currentPackageId,
  });

  @override
  State<_ChangePlanView> createState() => _ChangePlanViewState();
}

class _ChangePlanViewState extends State<_ChangePlanView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  static const List<PlanTab> _tabs = PlanTab.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final tab = _tabs[_tabController.index];
    context.read<ChangePlanBloc>().add(
      SwitchTab(tab: tab, packageId: widget.currentPackageId),
    );
  }

  void _onSearch(String query) {
    context.read<ChangePlanBloc>().add(
      SearchPackages(query: query, packageId: widget.currentPackageId),
    );
  }

  void _showSpeedFilter() {
    final bloc = context.read<ChangePlanBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColor.kMainBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SpeedFilterSheet(
            currentSpeed: bloc.state.speedFilter,
            onApply: (speed) {
              bloc.add(
                FilterBySpeed(speed: speed, packageId: widget.currentPackageId),
              );
            },
          ),
    );
  }

  String _tabLabel(PlanTab tab) {
    switch (tab) {
      case PlanTab.all:
        return 'All';
      case PlanTab.ottPlans:
        return 'OTT Plans';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChangePlanBloc, ChangePlanState>(
      listenWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == ActionStatus.success) {
          Navigator.pop(context);
          DialogUtil().showCustomSnackbar(
            context: context,
            content:
                'Plan changed successfully to ${state.selectedPackage?.packageName ?? ''}',
          );
        } else if (state.actionStatus == ActionStatus.error) {
          DialogUtil().showCustomSnackbar(
            context: context,
            content: state.errorMessage ?? 'Something went wrong',
            backgroundColor: AppColor.kSuspendedStatusText,
          );
        }
      },
      child: CommonAppBar(
        title: 'Change Plan',
        onBackPressed: () => Navigator.pop(context),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicator: const BoxDecoration(),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    padding: const EdgeInsets.all(4),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    tabs:
                        _tabs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tab = entry.value;
                          return Tab(
                            height: 32,
                            child: AnimatedBuilder(
                              animation: _tabController,
                              builder: (context, _) {
                                final isSelected =
                                    _tabController.index == index;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? AppColor.kPrimaryColor
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _tabLabel(tab),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : AppColor.kTabBarUnselectedText,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                // Search & filter (only for All tab)
                BlocBuilder<ChangePlanBloc, ChangePlanState>(
                  buildWhen: (prev, curr) => prev.activeTab != curr.activeTab,
                  builder: (context, state) {
                    if (state.activeTab != PlanTab.all) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearch,
                              decoration: InputDecoration(
                                hintText: 'Search Plan',
                                hintStyle: const TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14,
                                ),
                                prefixIcon: const Icon(Icons.search, size: 20),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _showSpeedFilter,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.tune,
                                size: 20,
                                color: AppColor.kPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children:
                        _tabs.map((tab) {
                          return _PlanTabContent(
                            tab: tab,
                            currentPackageId: widget.currentPackageId,
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),

            // Bottom Change Package button only when plan selected
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<ChangePlanBloc, ChangePlanState>(
                  builder: (context, state) {
                    final isLoading =
                        state.actionStatus == ActionStatus.loading;
                    final selectedPackage = state.selectedPackage;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            selectedPackage == null || isLoading
                                ? null
                                : () => _showConfirmationDialog(
                                  context,
                                  selectedPackage,
                                ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text('Change Package'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, PackageEntity package) {
    final bloc = context.read<ChangePlanBloc>();
    DialogUtil().showConfirmationSheet(
      context: context,
      title: 'Change Plan',
      content: 'Are you sure you want to change to ${package.packageName}?',
      onPositiveButtonClick: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder:
                (context) => BlocProvider.value(
                  value: bloc,
                  child: RechargePage(package: package),
                ),
          ),
        );
      },
    );
  }
}

/// Individual tab content with its own scroll controller for pagination
/// and AutomaticKeepAliveClientMixin to preserve state when switching tabs.
class _PlanTabContent extends StatefulWidget {
  final PlanTab tab;
  final String currentPackageId;

  const _PlanTabContent({required this.tab, required this.currentPackageId});

  @override
  State<_PlanTabContent> createState() => _PlanTabContentState();
}

class _PlanTabContentState extends State<_PlanTabContent>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels >=
  //       _scrollController.position.maxScrollExtent - 200) {
  //     context.read<ChangePlanBloc>().add(
  //       LoadMorePackages(tab: widget.tab, packageId: widget.currentPackageId),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<ChangePlanBloc, ChangePlanState>(
      buildWhen: (prev, curr) {
        final prevTab = prev.tabStates[widget.tab];
        final currTab = curr.tabStates[widget.tab];
        return prevTab != currTab ||
            prev.selectedPackageId != curr.selectedPackageId;
      },
      builder: (context, state) {
        final tabState = state.tabStates[widget.tab] ?? const TabPlanState();

        if (tabState.status == ListPlanStatus.loading) {
          return const ListShimmer();
        }

        if (tabState.status == ListPlanStatus.error) {
          return RetryWidget(
            errorMessage: tabState.errorMessage ?? 'Something went wrong',
            onRetry:
                () => context.read<ChangePlanBloc>().add(
                  LoadPackages(
                    tab: widget.tab,
                    packageId: widget.currentPackageId,
                  ),
                ),
          );
        }

        if (tabState.packages.isEmpty &&
            tabState.status == ListPlanStatus.success) {
          return NoDataFound(errorMessage: 'No packages available');
        }

        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.only(left: 16, right: 10, bottom: 84),
          itemCount:
              tabState.packages.length +
              (tabState.status == ListPlanStatus.loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= tabState.packages.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final package = tabState.packages[index];
            return PlanTile(
              package: package,
              isSelected: state.selectedPackageId == package.packageId,
              onTap:
                  () => context.read<ChangePlanBloc>().add(
                    SelectPackage(package.packageId),
                  ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
        );
      },
    );
  }
}
