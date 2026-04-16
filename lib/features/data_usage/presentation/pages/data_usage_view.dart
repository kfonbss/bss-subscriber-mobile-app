import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/app_styles.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/entity/active_packages_details_entity.dart';
import 'package:kfon_subscriber/features/data_usage/domain/entity/data_usage_entity.dart';
import 'package:kfon_subscriber/features/data_usage/domain/params/get_subscriber_data_usage_params.dart';
import 'package:kfon_subscriber/features/data_usage/domain/repository/data_usage_repository.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/bloc/data_usage_bloc.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/bloc/data_usage_event.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/bloc/data_usage_state.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/restart_modem_page.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/session_history_detail_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/page_component/package_info_card.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_box.dart';
import 'package:kfon_subscriber/service_locator.dart';

part '../components/active_session_card.dart';
part '../components/data_usage_chart.dart';
part '../components/data_usage_session_history_card.dart';

class DataUsageView extends StatefulWidget {
  final String subscriberUuid;
  final ActivePackagesDetailsEntity? entity;

  const DataUsageView(
      {super.key, required this.subscriberUuid, required this.entity});

  @override
  State<DataUsageView> createState() => _DataUsageViewState();
}

class _DataUsageViewState extends State<DataUsageView> {
  static const _modemAvatarBg = Color(0x0D8D0247); // kPrimaryColor @ 5% opacity
  static const _modemIconColorFilter =
      ColorFilter.mode(AppColor.kPrimaryColor, BlendMode.srcIn);
  static const _cardRadius = BorderRadius.all(Radius.circular(12));

  late DataUsageBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DataUsageBloc(repository: sl<DataUsageRepository>());
    _bloc.add(
      LoadSubscriberDataUsage(
        params: GetSubscriberDataUsageParams(
          subscriberUuid: widget.subscriberUuid,
          period: 'month',
        ),
      ),
    );
  }

  void _onRetry() {
    final old = _bloc;
    final newBloc = DataUsageBloc(repository: sl<DataUsageRepository>());
    newBloc.add(
      LoadSubscriberDataUsage(
        params: GetSubscriberDataUsageParams(
          subscriberUuid: widget.subscriberUuid,
          period: 'month',
        ),
      ),
    );
    setState(() => _bloc = newBloc);
    old.close();
  }

  void _onPeriodChanged(String period) {
    _bloc.add(
      LoadSubscriberDataUsage(
        params: GetSubscriberDataUsageParams(
          subscriberUuid: widget.subscriberUuid,
          period: period,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CommonAppBar(
      title: context.bssSubL10n.viewUsage,
      onBackPressed: () => Navigator.pop(context),
      appbarColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      circleColor: Colors.white,
      titleColor: Colors.white,
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 200.h,
                child: SvgPicture.asset(
                  'assets/images/speed_test_background.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 140),
                child: BlocBuilder<DataUsageBloc, DataUsageState>(
                bloc: _bloc,
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
                            dataUsageState.error ?? context.bssSubL10n.somethingWentWrong,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColor.kTextSecondaryDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _onRetry,
                            child: Text(context.bssSubL10n.retry),
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
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RestartModemPage(),
                                ),
                              );
                            },
                            borderRadius: _cardRadius,
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
                                    backgroundColor: _modemAvatarBg,
                                    child: SvgPicture.asset(
                                      'assets/icons/modem_restart.svg',
                                      colorFilter: _modemIconColorFilter,
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      context.bssSubL10n.restartModem,
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
        ),   // closes Stack
      ),     // closes SizedBox.expand
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
            context.bssSubL10n.noDataFound,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColor.kTextSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
