import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';
import 'package:kfon_subscriber/features/autopay/presentation/bloc/autopay_bloc.dart';
import 'package:kfon_subscriber/features/autopay/presentation/bloc/autopay_event.dart';
import 'package:kfon_subscriber/features/autopay/presentation/bloc/autopay_state.dart';
import 'package:kfon_subscriber/features/autopay/presentation/widgets/autopay_widgets.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';

/// "Remove from auto-pay?" confirmation. "Yes, remove" revokes the mandate;
/// the sheet closes itself once the revoke succeeds.
class AutopayRemoveBottomSheet extends StatelessWidget {
  const AutopayRemoveBottomSheet({super.key, required this.details});

  final AutopayMandateDetailsEntity details;

  static Future<void> show(
    BuildContext context, {
    required AutopayMandateDetailsEntity details,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: context.read<AutopayBloc>(),
            child: AutopayRemoveBottomSheet(details: details),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return BlocConsumer<AutopayBloc, AutopayState>(
      listenWhen: (_, current) => current.action == AutopayAction.revokeSuccess,
      listener: (context, _) => Navigator.of(context).pop(),
      builder: (context, state) {
        final isRevoking = state.isRevoking;
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: const BoxDecoration(
                  color: AppColor.kRemoveIconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.delete,
                    height: 30.h,
                    width: 30.w,
                    colorFilter: const ColorFilter.mode(
                      AppColor.kErrorRed,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                l10n.removeFromAutoPayQuestion,
                textAlign: TextAlign.center,
                style: autopayText(
                  20,
                  FontWeight.w600,
                  AppColor.kSheetTitle,
                  height: 1.54,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.removeAutopayMessage,
                textAlign: TextAlign.center,
                style: autopayText(
                  14,
                  FontWeight.w500,
                  AppColor.kSheetMessage,
                  height: 1.47,
                ),
              ),
              SizedBox(height: 20.h),
              AutopayPlanSummaryCard(details: details),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  onPressed:
                      isRevoking
                          ? null
                          : () => context.read<AutopayBloc>().add(
                            const RevokeAutopay(),
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColor.kErrorRed,
                    disabledBackgroundColor: AppColor.kErrorRed.withValues(
                      alpha: 0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      isRevoking
                          ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Text(
                            l10n.yesRemove,
                            style: autopayText(
                              14,
                              FontWeight.w500,
                              Colors.white,
                            ),
                          ),
                ),
              ),
              SizedBox(height: 8.h),
              TextButton(
                onPressed:
                    isRevoking ? null : () => Navigator.of(context).pop(),
                child: Text(
                  l10n.cancel,
                  style: autopayText(14, FontWeight.w500, AppColor.kStone500),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
