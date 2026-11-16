import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/self_care/domain/entity/connected_device_entity.dart';
import 'package:kfon_subscriber/features/self_care/domain/repository/connected_devices_repository.dart';
import 'package:kfon_subscriber/features/self_care/presentation/bloc/connected_devices_bloc.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';

class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({super.key});

  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  late final ConnectedDevicesBloc _bloc;

  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.30,
  );

  @override
  void initState() {
    super.initState();
    _bloc = ConnectedDevicesBloc(repository: sl<ConnectedDevicesRepository>())
      ..add(const LoadConnectedDevices());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _reload() => _bloc.add(const LoadConnectedDevices());

  /// Completes when the reload finishes, so the pull-to-refresh spinner
  /// stays up for the whole request.
  Future<void> _onPullToRefresh() async {
    _reload();
    await _bloc.stream.firstWhere(
      (s) => s.status != ConnectedDevicesStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.deviceManagement,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: BlocBuilder<ConnectedDevicesBloc, ConnectedDevicesState>(
          bloc: _bloc,
          builder: (context, state) {
            final isLoading = state.status == ConnectedDevicesStatus.loading;
            return Column(
              spacing: 20, // Design: 20 from section title to first card.
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.connectedDevices, style: _titleStyle),
                    IconButton(
                      onPressed: isLoading ? null : _reload,
                      tooltip: l10n.retry,
                      visualDensity: VisualDensity.compact,
                      icon: Opacity(
                        opacity: isLoading ? 0.4 : 1,
                        child: Image.asset(
                          AppAssets.refresh,
                          width: 20.w,
                          height: 20.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(child: _buildBody(l10n, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BssSubLocalizations l10n, ConnectedDevicesState state) {
    final hasDevices = state.devices.isNotEmpty;

    switch (state.status) {
      case ConnectedDevicesStatus.initial:
      case ConnectedDevicesStatus.loading:
        // On a refresh, keep the current list on screen instead of
        // flashing the shimmer.
        if (!hasDevices) {
          return ListShimmer(
            itemCount: 4,
            itemHeight: 77.h,
            separatorHeight: 13.h,
            padding: EdgeInsets.zero,
            itemBorderRadius: const BorderRadius.all(Radius.circular(12)),
          );
        }
      case ConnectedDevicesStatus.error:
        if (!hasDevices) {
          return RetryWidget(
            errorMessage: state.error ?? l10n.noDataFound,
            onRetry: _reload,
          );
        }
      case ConnectedDevicesStatus.loaded:
        break;
    }

    return RefreshIndicator(
      onRefresh: _onPullToRefresh,
      child:
          hasDevices
              ? ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.devices.length,
                itemBuilder:
                    (context, index) =>
                        _DeviceCard(device: state.devices[index]),
              )
              // Scrollable so pull-to-refresh still works on an empty list.
              : LayoutBuilder(
                builder:
                    (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: NoDataFound(
                          errorMessage: l10n.noConnectedDevices,
                        ),
                      ),
                    ),
              ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final ConnectedDeviceEntity device;

  const _DeviceCard({required this.device});

  static final _iconContainerDecoration = ShapeDecoration(
    color: AppColor.kPrimaryTint,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(40)),
    ),
  );

  static final _headingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.30,
  );

  static final _subHeadingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    color: AppColor.kBlack70,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.30,
  );

  static final _statusStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.30,
  );

  /// Picks the closest icon we have for the reported device type.
  static String _iconFor(ConnectedDeviceEntity device) {
    final type = '${device.deviceType} ${device.deviceName}'.toLowerCase();
    if (type.contains('tv') || type.contains('television')) {
      return AppAssets.tv;
    }
    const computers = ['laptop', 'computer', 'desktop', 'pc', 'macbook'];
    if (computers.any(type.contains)) return AppAssets.laptop;
    return AppAssets.mobileTwo;
  }

  /// Device name, falling back to the type, then the MAC address.
  static String _titleFor(ConnectedDeviceEntity device, String fallback) {
    for (final value in [
      device.deviceName,
      device.deviceType,
      device.macAddress,
    ]) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return fallback;
  }

  /// true = online, false = offline, null = unknown/empty status.
  static bool? _isOnline(String status) {
    switch (status.trim().toLowerCase()) {
      case 'online':
      case 'active':
      case 'connected':
        return true;
      case 'offline':
      case 'inactive':
      case 'disconnected':
        return false;
    }
    return null;
  }

  /// "just now", "5 mins ago", "3 hours ago", "2 days ago", then a date.
  /// Shows the raw value if the backend sends something that isn't a date.
  static String _formatLastSeen(String raw, BssSubLocalizations l10n) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final diff = DateTime.now().difference(parsed.toLocal());
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return DateFormat('MMM dd, yyyy').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final lastSeen = device.lastSeen.trim();
    final online = _isOnline(device.status);
    final statusLabel = switch (online) {
      true => l10n.online,
      false => l10n.offline,
      null => device.status.trim(),
    };
    final statusColor =
        online == true ? AppColor.kActiveGreen : AppColor.kBodyTextGrey;
    final details = [
      device.ipAddress,
      device.connectionType,
    ].where((v) => v.trim().isNotEmpty).join(' · ');

    // Design: white, radius 12, no shadow; 13 gap between cards.
    return Card(
      margin: EdgeInsets.only(bottom: 13.h),
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          spacing: 12.w,
          children: [
            // Design: 53 circle with a 22 icon.
            Container(
              width: 53.w,
              height: 53.w,
              alignment: Alignment.center,
              decoration: _iconContainerDecoration,
              child: SvgPicture.asset(
                _iconFor(device),
                width: 22.w,
                height: 22.w,
                colorFilter: ColorFilter.mode(
                  AppColor.kPrimaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Text(
                    _titleFor(device, l10n.connectedDevices),
                    style: _headingStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (details.isNotEmpty)
                    Text(
                      details,
                      style: _subHeadingStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (lastSeen.isNotEmpty)
                    Text(
                      l10n.lastSync(_formatLastSeen(lastSeen, l10n)),
                      style: _subHeadingStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (statusLabel.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    statusLabel,
                    style: _statusStyle.copyWith(color: statusColor),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
