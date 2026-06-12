// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:kfon_subscriber/core/constant/constant_colors.dart';
// import 'package:kfon_subscriber/core/util/dialog_util.dart';
// import 'package:kfon_subscriber/core/util/sizer.dart';
// import 'package:kfon_subscriber/features/change_plan/domain/entity/package_entity.dart';
// import 'package:kfon_subscriber/features/change_plan/domain/entity/package_new_entity.dart';
// import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_payment_status_entity.dart';
// import 'package:kfon_subscriber/features/change_plan/domain/params/recharge_change_plan_params.dart';
// import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_bloc.dart';
// import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_event.dart';
// import 'package:kfon_subscriber/features/change_plan/presentation/bloc/change_plan_state.dart';
// import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/plan_tile.dart';
// import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/plan_tile_new.dart';
// import 'package:kfon_subscriber/features/change_plan/presentation/pages/payment_webview_page.dart';
// import 'package:kfon_subscriber/features/home/presentation/bloc/home_bloc.dart';
// import 'package:kfon_subscriber/features/home/presentation/bloc/home_event.dart';
// import 'package:kfon_subscriber/l10n/l10n_ext.dart';
// import 'package:kfon_subscriber/painter/dashed_line_painter.dart';
// import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
// import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
//
// class RechargePage extends StatelessWidget {
//   final PackageItemEntity package;
//
//   const RechargePage({super.key, required this.package});
//
//   // ── Shared dialog constants ──────────────────────────────────────────────────
//   // 0x80 = 128 = 50% of 255 → Colors.black @ 50% opacity
//   static const _backdropColor = Color(0x80000000);
//   static const _dialogContainerDecoration = BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.all(Radius.circular(20)),
//   );
//
//   // ElevatedButton.styleFrom() is not const — computed once as static final.
//   static final _dialogButtonStyle = ElevatedButton.styleFrom(
//     backgroundColor: AppColor.kPrimaryColor,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(Radius.circular(8)),
//     ),
//   );
//
//   // DashedLinePainter has no const constructor — computed once as static final.
//   // 0x1A = 26 ≈ 0.1 × 255 → Colors.black @ 10% opacity
//   static final _dashedPainter = DashedLinePainter(
//     color: const Color(0x1A000000),
//     strokeWidth: 1,
//   );
//   static const _contentPadding = EdgeInsets.only(
//     left: 20,
//     right: 20,
//     top: 140,
//     bottom: 20,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     final l10n = context.bssSubL10n;
//
//     return CommonAppBar(
//       title: l10n.recharge,
//       onBackPressed: () => Navigator.pop(context),
//       appbarColor: Colors.transparent,
//       extendBodyBehindAppBar: true,
//       circleColor: Colors.white,
//       titleColor: Colors.white,
//       body: BlocConsumer<ChangePlanBloc, ChangePlanState>(
//         listenWhen:
//             (previous, current) =>
//                 previous.actionStatus != current.actionStatus ||
//                 previous.paymentStatus != current.paymentStatus,
//         listener: (context, state) {
//           if (state.paymentStatus == PaymentStatus.success &&
//               state.paymentStatusEntity != null) {
//             context.read<HomeBloc>().add(const GetHomeData(loadPackage: false));
//             _showTopUpSuccessDialog(state.paymentStatusEntity!, context);
//           } else if (state.paymentStatus == PaymentStatus.failed) {
//             _showTopUpFailDialog(package.renewalFee, context);
//           } else if (state.actionStatus == ActionStatus.success &&
//               state.redirectEntity != null) {
//             Navigator.of(context).pop();
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder:
//                     (context) => PaymentWebViewPage(
//                       redirectEntity: state.redirectEntity!,
//                     ),
//               ),
//             ).then((result) {
//               if (!context.mounted) return;
//               if (result == PaymentResult.success) {
//                 if (state.orderId != null) {
//                   context.read<ChangePlanBloc>().add(
//                     FetchRechargePaymentStatus(orderId: state.orderId!),
//                   );
//                 }
//               } else if (result == PaymentResult.failed) {
//                 _showTopUpFailDialog(package.renewalFee, context);
//               } else if (result == PaymentResult.cancelled) {
//                 DialogUtil().showCustomSnackbar(
//                   context: context,
//                   content: l10n.rechargePaymentCancelled,
//                   backgroundColor: AppColor.kPendingOrange,
//                 );
//               }
//             });
//           } else if (state.actionStatus == ActionStatus.error) {
//             Navigator.pop(context);
//             DialogUtil().showCustomSnackbar(
//               context: context,
//               content: l10n.rechargeFailedError(state.errorMessage ?? ''),
//               backgroundColor: AppColor.kSuspendedStatusText,
//             );
//           }
//         },
//         buildWhen:
//             (previous, current) =>
//                 previous.actionStatus != current.actionStatus,
//         builder: (context, state) {
//           return Stack(
//             children: [
//               SizedBox(
//                 width: double.infinity,
//                 height: 200.h,
//                 child: SvgPicture.asset(
//                   'assets/images/speed_test_background.svg',
//                   fit: BoxFit.fill,
//                 ),
//               ),
//               Padding(
//                 padding: _contentPadding,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     PlanTileNew(
//                       package: package,
//                       isSelected: true,
//                       showSelectedBorder: false,
//                       onTap: () {},
//                     ),
//                     PrimaryButton(
//                       label: l10n.payNow,
//                       isLoading: state.actionStatus == ActionStatus.loading,
//                       onClicked:
//                           () => showPaymentMethodSheet(
//                             context,
//                             onNext: (gateway) async {
//                               if (context.mounted) {
//                                 context.read<ChangePlanBloc>().add(
//                                   RechargeChangePlan(
//                                     params: RechargeChangePlanParams(
//                                       packageId: package.id,
//                                       gateway: gateway,
//                                       amount: package.renewalFee,
//                                       durationDays: package.renewPeriod,
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   void showPaymentMethodSheet(
//     BuildContext context, {
//     required Function(String gateway) onNext,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder:
//           (_) => BlocProvider.value(
//             value: context.read<ChangePlanBloc>(),
//             child: PaymentMethodSheet(onNext: (gateway) => onNext(gateway)),
//           ),
//     );
//   }
//
//   void _showTopUpSuccessDialog(
//     RechargePaymentStatusEntity paymentStatus,
//     BuildContext context,
//   ) {
//     final l10n = context.bssSubL10n;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: _backdropColor,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.symmetric(horizontal: 30),
//           child: Container(
//             decoration: _dialogContainerDecoration,
//             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SvgPicture.asset(
//                   'assets/images/top-up_successfull.svg',
//                   width: 80,
//                   height: 80,
//                 ),
//                 const SizedBox(height: 26),
//                 Text(
//                   l10n.rechargeSuccessful,
//                   style: const TextStyle(
//                     color: AppColor.kTextSecondaryDark,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     height: 1.3,
//                     fontFamily: 'GeneralSans',
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   l10n.rechargeSuccessMessage(
//                     paymentStatus.amount.toStringAsFixed(2),
//                   ),
//                   style: const TextStyle(
//                     color: AppColor.kDarkBlue,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     height: 1.54,
//                     fontFamily: 'GeneralSans',
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 18),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(horizontal: 20.w),
//                   height: 1,
//                   child: CustomPaint(painter: _dashedPainter),
//                 ),
//                 const SizedBox(height: 18),
//                 Text(
//                   l10n.transactionId(paymentStatus.txnId),
//                   style: const TextStyle(
//                     color: AppColor.kDarkBlue,
//                     fontSize: 14,
//                     fontFamily: 'GeneralSans',
//                     fontWeight: FontWeight.w500,
//                     height: 1.43,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       Navigator.pop(context);
//                     },
//                     style: _dialogButtonStyle,
//                     child: Text(
//                       l10n.ok,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         height: 1.3,
//                         fontFamily: 'GeneralSans',
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showTopUpFailDialog(double amount, BuildContext context) {
//     final l10n = context.bssSubL10n;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: _backdropColor,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.symmetric(horizontal: 30),
//           child: Container(
//             decoration: _dialogContainerDecoration,
//             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SvgPicture.asset(
//                   'assets/images/top-up_fail.svg',
//                   width: 80,
//                   height: 80,
//                 ),
//                 const SizedBox(height: 26),
//                 Text(
//                   l10n.rechargeFailed,
//                   style: const TextStyle(
//                     color: AppColor.kTextSecondaryDark,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     height: 1.3,
//                     fontFamily: 'GeneralSans',
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   l10n.rechargeFailedMessage,
//                   style: const TextStyle(
//                     color: AppColor.kDarkBlue,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     height: 1.54,
//                     fontFamily: 'GeneralSans',
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 13),
//                 Text(
//                   l10n.topUpFailedRetryMessage,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: AppColor.kDarkBlue,
//                     fontSize: 13,
//                     fontFamily: 'GeneralSans',
//                     fontWeight: FontWeight.w500,
//                     height: 1.54,
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(horizontal: 20.w),
//                   height: 1,
//                   child: CustomPaint(painter: _dashedPainter),
//                 ),
//                 const SizedBox(height: 24),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       Navigator.pop(context);
//                     },
//                     style: _dialogButtonStyle,
//                     child: Text(
//                       l10n.ok,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         height: 1.3,
//                         fontFamily: 'GeneralSans',
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class PaymentMethodSheet extends StatefulWidget {
//   final Function(String gateway) onNext;
//
//   const PaymentMethodSheet({super.key, required this.onNext});
//
//   @override
//   State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
// }
//
// class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
//   String _selected = 'HDFC';
//
//   static const _methods = [
//     PaymentMethod(name: 'HDFC', logo: 'assets/images/hdfc_logo.png'),
//     PaymentMethod(name: 'IKM', logo: 'assets/images/ikm_logo.png'),
//   ];
//
//   // ── Static decorations ───────────────────────────────────────────────────────
//   static const _sheetDecoration = BoxDecoration(
//     color: AppColor.kWarmBackground,
//     borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//   );
//   static const _handleDecoration = BoxDecoration(
//     color: AppColor.kDisabledGrey,
//     borderRadius: BorderRadius.all(Radius.circular(2)),
//   );
//
//   // Sizer.sp is fixed after MaterialApp.builder — computed once as static final.
//   static final _titleStyle = TextStyle(
//     fontSize: 16.sp,
//     fontFamily: 'GeneralSans',
//     fontWeight: FontWeight.w600,
//     height: 1.30,
//     color: Colors.black,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     final l10n = context.bssSubL10n;
//
//     return Container(
//       decoration: _sheetDecoration,
//       padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Drag handle
//           Center(
//             child: Container(
//               width: 40.w,
//               height: 4.h,
//               decoration: _handleDecoration,
//             ),
//           ),
//           SizedBox(height: 20.h),
//
//           Text(l10n.paymentMethod, style: _titleStyle),
//           SizedBox(height: 16.h),
//
//           // Payment options — extracted to StatelessWidget for identity tracking.
//           ..._methods.map(
//             (m) => _PaymentOption(
//               method: m,
//               isSelected: _selected == m.name,
//               onTap: () => setState(() => _selected = m.name),
//             ),
//           ),
//
//           SizedBox(height: 80.h),
//
//           BlocBuilder<ChangePlanBloc, ChangePlanState>(
//             buildWhen:
//                 (previous, current) =>
//                     previous.actionStatus != current.actionStatus,
//             builder: (context, state) {
//               return PrimaryButton(
//                 label: l10n.next,
//                 isLoading: state.actionStatus == ActionStatus.loading,
//                 onClicked: () => widget.onNext(_selected),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Payment option card ───────────────────────────────────────────────────────
// // Extracted from _buildOption helper method so Flutter can track identity
// // and skip rebuilds when isSelected has not changed.
// class _PaymentOption extends StatelessWidget {
//   final PaymentMethod method;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _PaymentOption({
//     required this.method,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   // 0x0A = 10 ≈ 0.04 × 255 → Colors.black @ 4% opacity
//   static const _cardDecoration = BoxDecoration(
//     color: Colors.white,
//     borderRadius: BorderRadius.all(Radius.circular(14)),
//     boxShadow: [
//       BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
//     ],
//   );
//   static const _logoDecoration = ShapeDecoration(
//     color: Colors.white,
//     shape: RoundedRectangleBorder(
//       side: BorderSide(width: 1, color: AppColor.kBorderLightGrey),
//       borderRadius: BorderRadius.all(Radius.circular(6)),
//     ),
//   );
//   static const _selectedRadioDecoration = BoxDecoration(
//     shape: BoxShape.circle,
//     color: AppColor.kPrimaryColor,
//   );
//
//   // Border.fromBorderSide has a const constructor; Border.all does not.
//   static const _unselectedRadioDecoration = BoxDecoration(
//     shape: BoxShape.circle,
//     color: Colors.transparent,
//     border: Border.fromBorderSide(
//       BorderSide(color: AppColor.kDisabledGrey, width: 1.5),
//     ),
//   );
//   static const _centerDotDecoration = BoxDecoration(
//     color: Colors.white,
//     shape: BoxShape.circle,
//   );
//   static final _methodNameStyle = TextStyle(
//     fontSize: 15.sp,
//     fontWeight: FontWeight.w600,
//     color: AppColor.kRichBlack,
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12.h),
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//         decoration: _cardDecoration,
//         child: Row(
//           children: [
//             Container(
//               width: 46.w,
//               height: 46.h,
//               padding: const EdgeInsets.all(5),
//               decoration: _logoDecoration,
//               child: Image.asset(method.logo),
//             ),
//             SizedBox(width: 16.w),
//             Expanded(child: Text(method.name, style: _methodNameStyle)),
//             Container(
//               width: 20.w,
//               height: 20.w,
//               decoration:
//                   isSelected
//                       ? _selectedRadioDecoration
//                       : _unselectedRadioDecoration,
//               child:
//                   isSelected
//                       ? Center(
//                         child: Container(
//                           width: 8.w,
//                           height: 8.w,
//                           decoration: _centerDotDecoration,
//                         ),
//                       )
//                       : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class PaymentMethod {
//   final String name;
//   final String logo;
//
//   const PaymentMethod({required this.name, required this.logo});
// }
