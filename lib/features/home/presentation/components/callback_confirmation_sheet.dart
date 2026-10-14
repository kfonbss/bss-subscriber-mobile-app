import 'package:kfon_subscriber/features/home/domain/repository/home_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

void showCallbackConfirmation(BuildContext context) {
  final l10n = context.bssSubL10n;
  showAppModalBottomSheet(
    context: context,
    // Call Back design: radius 20, 50×5 handle 20 from the top.
    topRadius: 20,
    dragHandleSize: Size(50.w, 5.h),
    dragHandlePadding: EdgeInsets.only(top: 20.h, bottom: 16.h),
    builder: (BuildContext sheetContext) {
      bool isLoading = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            // 32 below the buttons; the system draws the home indicator.
            padding: EdgeInsets.fromLTRB(20, 0, 20, 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.callBack,
                  style: TextStyle(
                    color: Color(0xFF262629),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'General Sans',
                    height: 1.4.h,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  l10n.confirmCallBackRequest,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0F1121),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'General Sans',
                    height: 1.6.h,
                  ),
                ),
                SizedBox(height: 30.h),
                Padding(
                  // 393 design: 353 − 16 − 21 gap = 2 × 158 buttons.
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: l10n.cancel,
                          borderRadius: 10,
                          height: 52.h,
                          backgroundColor: Colors.transparent,
                          onClicked: isLoading ? null : () => Navigator.pop(sheetContext),
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'General Sans',
                            height: 1.3.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 21.w),
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.yes,
                          isLoading: isLoading,
                          borderRadius: 10,
                          height: 52.h,
                          onClicked: isLoading
                              ? null
                              : () async {
                                  setState(() => isLoading = true);
                                  final result = await sl<HomeRepository>().requestCallback();
                                  if (!sheetContext.mounted) return;
                                  setState(() => isLoading = false);
                                  Navigator.pop(sheetContext);
                                  result.fold(
                                    (failure) => DialogUtil().showCustomSnackbar(
                                      context: context,
                                      content: failure.message,
                                      isError: true,
                                    ),
                                    (_) => DialogUtil().showCustomSnackbar(
                                      context: context,
                                      content: l10n.ticketCreatedSuccessfully,
                                    ),
                                  );
                                },
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'General Sans',
                            height: 1.3.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
