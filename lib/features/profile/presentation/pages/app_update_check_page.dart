import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateCheckPage extends StatefulWidget {
  const AppUpdateCheckPage({super.key});

  @override
  State<AppUpdateCheckPage> createState() => _AppUpdateCheckPageState();
}

class _AppUpdateCheckPageState extends State<AppUpdateCheckPage> {
  bool _isChecking = false;
  bool _isUpdating = false;
  bool _isUpdateAvailable = false;
  AppUpdateInfo? _updateInfo;
  final DialogUtil _dialogUtil = DialogUtil();

  /// Read once; a FutureBuilder future must not be recreated on every build.
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  /// Play in-app updates exist only on Android (the plugin throws elsewhere).
  bool get _isSupported => !kIsWeb && Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    // _checkForUpdate reads context.bssSubL10n (an inherited widget), which
    // isn't allowed until initState has finished — start after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkForUpdate(isAutomatic: true);
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    _dialogUtil.showCustomSnackbar(
      context: context,
      content: message,
      isError: isError,
    );
  }

  Future<void> _checkForUpdate({bool isAutomatic = false}) async {
    final l10n = context.bssSubL10n;
    if (!_isSupported) {
      setState(() => _isUpdateAvailable = false);
      if (!isAutomatic) _showMessage(l10n.updatesViaAppStore);
      return;
    }

    setState(() => _isChecking = true);
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      debugPrint('🔄 App update info: $updateInfo');
      if (!mounted) return;

      // An immediate update the user left half-way stays "in progress";
      // Play expects the app to resume it.
      final inProgress =
          updateInfo.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress;
      setState(() {
        _updateInfo = updateInfo;
        _isUpdateAvailable =
            inProgress ||
            updateInfo.updateAvailability == UpdateAvailability.updateAvailable;
        _isChecking = false;
      });

      if (inProgress) {
        await _performUpdate();
      } else if (!isAutomatic) {
        _showMessage(
          _isUpdateAvailable
              ? l10n.updateAvailable
              : l10n.noNewUpdatesAvailable,
        );
      }
    } catch (e) {
      // e.g. a debug / sideloaded install that Play doesn't own
      // ("Install Error(-10)"): log the details, show a readable message.
      debugPrint('❌ App update check failed: $e');
      if (!mounted) return;
      setState(() => _isChecking = false);
      if (!isAutomatic) {
        _showMessage(l10n.unableToCheckForUpdates, isError: true);
      }
    }
  }

  /// Immediate update when Play allows it (or one is already in progress),
  /// otherwise a flexible update installed once the download completes.
  Future<void> _performUpdate() async {
    final info = _updateInfo;
    if (_isUpdating || info == null) return;
    final l10n = context.bssSubL10n;
    setState(() => _isUpdating = true);
    try {
      final inProgress =
          info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress;
      AppUpdateResult result;
      if (inProgress || info.immediateUpdateAllowed) {
        result = await InAppUpdate.performImmediateUpdate();
      } else if (info.flexibleUpdateAllowed) {
        // Completes when the download has finished (or the user declined).
        result = await InAppUpdate.startFlexibleUpdate();
        if (result == AppUpdateResult.success) {
          await InAppUpdate.completeFlexibleUpdate();
        }
      } else {
        result = AppUpdateResult.inAppUpdateFailed;
      }

      switch (result) {
        case AppUpdateResult.success:
          break;
        case AppUpdateResult.userDeniedUpdate:
          _showMessage(l10n.updateCancelled);
        case AppUpdateResult.inAppUpdateFailed:
          _showMessage(l10n.updateFailedTryAgain, isError: true);
      }
    } catch (e) {
      debugPrint('❌ App update failed: $e');
      _showMessage(l10n.updateFailedTryAgain, isError: true);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    bool isLoading = false,
  }) {
    return Container(
      height: 77.h,
      margin: EdgeInsets.only(bottom: 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: Color(0xFFEAEAEA), width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Builder(
              builder: (context) {
                double containerSize;
                double iconSize;
                if (context.isTablet) {
                  containerSize = 53.0 * 1.2;
                  iconSize = 18.0 * 1.2;
                } else {
                  containerSize = 53.w;
                  iconSize = 18.w;
                }
                return Container(
                  width: containerSize,
                  height: containerSize,
                  decoration: BoxDecoration(
                    color: AppColor.kIconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        isLoading
                            ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.kPrimaryColor,
                              ),
                            )
                            : SvgPicture.asset(
                              AppAssets.appUpdateCheck,
                              width: iconSize,
                              height: iconSize,
                              colorFilter: ColorFilter.mode(
                                AppColor.kPrimaryColor,
                                BlendMode.srcIn,
                              ),
                            ),
                  ),
                );
              },
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      color: const Color(0xFF0F1121),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3.h,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      color: Colors.black.withOpacity(0.7),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.3.h,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.appUpdateCheck,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Version Section
                  Text(
                    l10n.currentVersion,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      color: const Color(0xFF0F1121),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3.h,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  FutureBuilder<PackageInfo>(
                    future: _packageInfo,
                    builder: (context, snapshot) {
                      // No made-up "v1.0.0" while the real version loads.
                      final version =
                          snapshot.hasData ? 'v${snapshot.data!.version}' : '';
                      return _buildInfoCard(
                        title: l10n.appVersion,
                        subtitle: l10n.version(version),
                      );
                    },
                  ),

                  SizedBox(height: 5.h),
                  // Update Status Section
                  Text(
                    l10n.updateStatus,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      color: const Color(0xFF0F1121),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3.h,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoCard(
                    title:
                        _isChecking
                            ? l10n.checkingForUpdate
                            : (_isUpdateAvailable
                                ? l10n.updateAvailable
                                : l10n.upToDate),
                    subtitle:
                        _isChecking
                            ? l10n.pleaseWait
                            : (_isUpdateAvailable
                                ? l10n.newVersionAvailableToUpdate
                                : l10n.noNewUpdatesAvailable),
                    isLoading: _isChecking,
                  ),
                  SizedBox(height: 22.h),
                  // Informational text
                  Center(
                    child: SizedBox(
                      width: 236.w,
                      child: Text(
                        _isChecking
                            ? l10n.checkingForUpdatesOnPlayStore
                            : (_isUpdateAvailable
                                ? l10n.newUpdateReadyForDownload
                                : l10n
                                    .yourAppIsUpToDateWeWillNotifyYouWhenANewVersionIsAvailable),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'General Sans',
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.6.h,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 22.h),
                  // Button: Update Now if available, else Check For Update
                  if (_isUpdateAvailable)
                    PrimaryButton(
                      label: l10n.updateNow,
                      isLoading: _isChecking || _isUpdating,
                      onClicked: _performUpdate,
                      borderRadius: 10,
                      height: 52.h,
                    )
                  else
                    PrimaryButton(
                      label: l10n.checkForUpdate,
                      isLoading: _isChecking,
                      onClicked: () => _checkForUpdate(isAutomatic: false),
                      borderRadius: 10,
                      height: 52.h,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
