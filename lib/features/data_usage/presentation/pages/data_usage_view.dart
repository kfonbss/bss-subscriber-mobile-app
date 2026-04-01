library subscriber_data_usage_page;

import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';
import 'package:kfon_subscriber/features/data_usage/domain/params/get_subscriber_data_usage_params.dart';
import 'package:kfon_subscriber/features/data_usage/domain/repository/data_usage_repository.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/bloc/data_usage_bloc.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/bloc/data_usage_event.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/bloc/data_usage_state.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/session_history_detail_page.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/data_usage/domain/entity/data_usage_entity.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/restart_modem_page.dart';
import 'package:kfon_subscriber/presentation/page_component/package_info_card.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_box.dart';
import 'package:kfon_subscriber/service_locator.dart';

part '../components/data_usage_chart.dart';

part '../components/active_session_card.dart';

part '../components/data_usage_session_history_card.dart';

class DataUsageView extends StatefulWidget {
  final String subscriberUuid;
  final ActivePackagesDetailsEntity? entity;

  DataUsageView(
      {super.key, required this.subscriberUuid, required this.entity});

  @override
  State<DataUsageView> createState() => _DataUsageViewState();
}

class _DataUsageViewState extends State<DataUsageView> {
  late DataUsageBloc bloc;

  @override
  void initState() {
    super.initState();
    _loadDataUsage();
  }

  void _loadDataUsage() {
    bloc = DataUsageBloc(repository: sl<DataUsageRepository>());
    final state = bloc.state;
    if (state.status == DataUsageStatus.initial || state.data == null) {
      bloc.add(
        LoadSubscriberDataUsage(
          params: GetSubscriberDataUsageParams(
            subscriberUuid: widget.subscriberUuid,
            period: 'month',
          ),
        ),
      );
    }
  }

  void _onPeriodChanged(String period) {
    context.read<DataUsageBloc>().add(
      LoadSubscriberDataUsage(
        params: GetSubscriberDataUsageParams(
          subscriberUuid: widget.subscriberUuid,
          period: period,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CommonAppBar(
      title: 'View Usage',
      onBackPressed: () => Navigator.pop(context),
      appbarColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      circleColor: Colors.white,
      titleColor: Colors.white,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 200.h,
            child: SvgPicture.asset(
              'assets/images/speed_test_background.svg',
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 140),
              child: BlocBuilder<DataUsageBloc, DataUsageState>(
                bloc: bloc,
                buildWhen: (prev, curr) => prev.status != curr.status,
                builder: (context, state) {
                  final dataUsageState = state;

                  if (dataUsageState.status == DataUsageStatus.loading) {
                    return SingleChildScrollView(
                      child: AppShimmer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: double.infinity, height: 190.h),
                            const SizedBox(height: 24),
                            ShimmerBox(width: double.infinity, height: 270.h),
                            const SizedBox(height: 16),
                            ShimmerBox(width: double.infinity, height: 400.h),

                          ],
                        ),
                      ),
                    );
                  }

                  if (dataUsageState.status == DataUsageStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/filler.png',
                            width: 180,
                            height: 128,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            dataUsageState.error ?? 'Something went wrong',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColor.kTextSecondaryDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadDataUsage,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (dataUsageState.status == DataUsageStatus.loaded &&
                      dataUsageState.data != null) {
                    final dataUsage = dataUsageState.data!;

                    if (dataUsage.dataUsage == null) {
                      return _buildEmptyState(theme);
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PackageInfoCard(entity: widget.entity),
                          const SizedBox(height: 24),
                          _DataUsageChart(
                            graphData: dataUsage.dataUsage!.graphData,
                            period: dataUsage.period,
                            onPeriodChanged: _onPeriodChanged,
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RestartModemPage(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: AppStyles.boxDecorationMedium,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    minRadius: 24,
                                    maxRadius: 24,
                                    backgroundColor: AppColor.kPrimaryColor
                                        .withValues(alpha: 0.05),
                                    child: SvgPicture.asset(
                                      'assets/icons/modem_restart.svg',
                                      colorFilter: ColorFilter.mode(
                                        AppColor.kPrimaryColor,
                                        BlendMode.srcIn,
                                      ),
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Restart Modem',
                                      style: Theme
                                          .of(
                                        context,
                                      )
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColor.kLabelGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SessionCard(session: dataUsage.activeSession),
                          const SizedBox(height: 24),
                          DataUsageSessionHistoryCard(
                            sessionHistory: dataUsage.sessionHistory,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }

                  return _buildEmptyState(theme);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/filler.png',
            width: 180,
            height: 128,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'NoDataFound',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColor.kTextSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
