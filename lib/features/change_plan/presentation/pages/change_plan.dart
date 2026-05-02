import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/change_plan/domain/enums/subscriber_enums.dart';
import 'package:kfon_subscriber/features/change_plan/domain/repository/change_plan_repository.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_bloc.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_event.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/tab_plan_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/plan_tile.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/plan_tile_new.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/speed_filter_sheet.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/recharge_page.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';
import 'package:kfon_subscriber/service_locator.dart';

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
          (_) => ChangePlanBloc(repository: sl<ChangePlanRepository>())..add(
            LoadPackages(
              tab: PlanTab.all,
              packageId: currentPackageId,
              subscriberUuid: subscriberUuid,
            ),
          ),
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
  late final List<Widget> _tabViews;
  late List<String> _tabLabels;
  final TextEditingController _searchController = TextEditingController();

  static const List<PlanTab> _tabs = PlanTab.values;
  static const _filterIconDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  // Hoisted out of AnimatedBuilder.builder — that callback fires every frame
  // during a tab swipe (60 fps). Allocating BoxDecoration + TextStyle there
  // was generating two new heap objects per frame per tab.
  static const _selectedTabDecoration = BoxDecoration(
    color: AppColor.kPrimaryColor,
    borderRadius: BorderRadius.all(Radius.circular(25)),
  );
  static const _unselectedTabDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(25)),
  );
  static const _selectedTabTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const _unselectedTabTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColor.kTabBarUnselectedText,
  );

  // WidgetStateProperty.all allocates a _MaterialStatePropertyAll wrapper on
  // every build() call — hoist to static final so it's created once.
  static final _transparentOverlay = WidgetStateProperty.all<Color>(
    Colors.transparent,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _tabViews =
        _tabs
            .map(
              (tab) => _PlanTabContent(
                tab: tab,
                currentPackageId: widget.currentPackageId,
                subscriberUuid: widget.subscriberUuid,
              ),
            )
            .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.bssSubL10n;
    _tabLabels = _tabs.map((tab) => _tabLabel(tab, l10n)).toList();
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
      SwitchTab(
        tab: tab,
        packageId: widget.currentPackageId,
        subscriberUuid: widget.subscriberUuid,
      ),
    );
  }

  void _onSearch(String query) {
    context.read<ChangePlanBloc>().add(
      SearchPackages(
        query: query,
        packageId: widget.currentPackageId,
        subscriberUuid: widget.subscriberUuid,
      ),
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
                FilterBySpeed(
                  speed: speed,
                  packageId: widget.currentPackageId,
                  subscriberUuid: widget.subscriberUuid,
                ),
              );
            },
          ),
    );
  }

  String _tabLabel(PlanTab tab, BssSubLocalizations l10n) {
    switch (tab) {
      case PlanTab.all:
        return l10n.allPlans;
      case PlanTab.ottPlans:
        return l10n.ottPlans;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      title: l10n.changePlan,
      onBackPressed: () => Navigator.pop(context),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
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
                    overlayColor: _transparentOverlay,
                    tabs:
                        _tabs.asMap().entries.map((entry) {
                          final index = entry.key;
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
                                  decoration:
                                      isSelected
                                          ? _selectedTabDecoration
                                          : _unselectedTabDecoration,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _tabLabels[index],
                                    style:
                                        isSelected
                                            ? _selectedTabTextStyle
                                            : _unselectedTabTextStyle,
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
                    if (state.activeTab != PlanTab.all)
                      return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearch,
                              decoration: InputDecoration(
                                hintText: l10n.searchPlan,
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
                              decoration: _filterIconDecoration,
                              child: const Icon(
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
                    children: _tabViews,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Change Package button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<ChangePlanBloc, ChangePlanState>(
                buildWhen:
                    (prev, curr) =>
                        prev.actionStatus != curr.actionStatus ||
                        prev.selectedPackageId != curr.selectedPackageId,
                builder: (context, state) {
                  final isLoading = state.actionStatus == ActionStatus.loading;
                  final selectedPackage = state.selectedPackage;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          selectedPackage == null || isLoading
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder:
                                        (_) => BlocProvider.value(
                                          value: context.read<ChangePlanBloc>(),
                                          child: RechargePage(
                                            package: selectedPackage,
                                          ),
                                        ),
                                  ),
                                );
                              },
                      child:
                          isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(l10n.changePackage),
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

class _PlanTabContent extends StatefulWidget {
  final PlanTab tab;
  final String currentPackageId;
  final String subscriberUuid;

  const _PlanTabContent({
    required this.tab,
    required this.currentPackageId,
    required this.subscriberUuid,
  });

  @override
  State<_PlanTabContent> createState() => _PlanTabContentState();
}

class _PlanTabContentState extends State<_PlanTabContent>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isBottom) return;
    final state = context.read<ChangePlanBloc>().state;
    final tabState = state.tabStates[widget.tab];
    // Guard: only dispatch when loaded and not already paginating.
    // Without this guard the listener fires on every scroll tick that
    // satisfies _isBottom, flooding the BLoC event queue.
    if (tabState!.hasMore && tabState.status != ListPlanStatus.loadingMore) {
      context.read<ChangePlanBloc>().add(
        LoadMorePackages(
          tab: widget.tab,
          packageId: widget.currentPackageId,
          subscriberUuid: widget.subscriberUuid,
        ),
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.bssSubL10n;

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
            errorMessage: tabState.errorMessage ?? l10n.somethingWentWrong,
            onRetry:
                () => context.read<ChangePlanBloc>().add(
                  LoadPackages(
                    tab: widget.tab,
                    packageId: widget.currentPackageId,
                    subscriberUuid: widget.subscriberUuid,
                  ),
                ),
          );
        }

        if (tabState.packages.isEmpty &&
            tabState.status == ListPlanStatus.success) {
          return NoDataFound(errorMessage: l10n.noPackagesAvailable);
        }

        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.only(left: 16, right: 10, bottom: 84),
          itemCount: tabState.packages.length + (tabState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= tabState.packages.length && tabState.hasMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final package = tabState.packages[index];
            return PlanTileNew(
              key: ValueKey(package.id),
              package: package,
              isSelected: state.selectedPackageId == package.id,
              showSelectedBorder: true,
              onTap:
                  () => context.read<ChangePlanBloc>().add(
                    SelectPackage(package.id),
                  ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
        );
      },
    );
  }
}
