import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/offline_recharge/domain/entity/offline_recharge_data_entity.dart';
import 'package:kfon_subscriber/features/offline_recharge/domain/repository/offline_recharge_repository.dart';
import 'package:kfon_subscriber/features/offline_recharge/presentation/bloc/offline_recharge_bloc.dart';
import 'package:kfon_subscriber/features/offline_recharge/presentation/bloc/offline_recharge_event.dart';
import 'package:kfon_subscriber/features/offline_recharge/presentation/bloc/offline_recharge_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_box.dart';
import 'package:kfon_subscriber/service_locator.dart';

class OfflineRechargeBottomSheet extends StatefulWidget {
  final String subscriberUuid;

  const OfflineRechargeBottomSheet({super.key, required this.subscriberUuid});

  @override
  State<OfflineRechargeBottomSheet> createState() =>
      _OfflineRechargeBottomSheetState();
}

class _OfflineRechargeBottomSheetState
    extends State<OfflineRechargeBottomSheet> {
  static const _orange = AppColor.kStatusPendingOrange;
  late OfflineRechargeBloc _bloc;

  // ── Shared card decoration ───────────────────────────────────────────────────
  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
  // 0x1F = 31 ≈ 0.12 × 255 → Colors.black @ 12% opacity
  static const _sheetDecoration = BoxDecoration(
    color: AppColor.kWarmBackground,
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    boxShadow: [
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 40,
        offset: Offset(0, 8),
      ),
    ],
  );
  static const _avatarDecoration = BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [Color(0xFF6A4FA3), Color(0xFFA0522D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
  static const _statsDecoration = ShapeDecoration(
    color: AppColor.kSecondaryBackgroundColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
  static const _badgeDecoration = BoxDecoration(
    color: AppColor.kStatusFailBg,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  // Sizer-based text styles — computed once as static final.
  static final _emojiStyle = TextStyle(fontSize: 22.sp);
  static final _userNameStyle = TextStyle(
    fontSize: 16.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.30,
    color: AppColor.kRichBlack,
  );
  static final _displayNameStyle = TextStyle(
    fontSize: 10.sp,
    color: const Color(0xFF888888),
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.30,
  );
  static final _badgeTextStyle = TextStyle(
    fontSize: 10.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.30,
    color: AppColor.kStatusFailRed,
  );

  @override
  void initState() {
    super.initState();
    _bloc = OfflineRechargeBloc(repository: sl<OfflineRechargeRepository>());
    _bloc.add(GetData(subscriberUuid: widget.subscriberUuid));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfflineRechargeBloc, OfflineRechargeState>(
      bloc: _bloc,
      listener: (context, state) {
        Navigator.pop(context);
        if (state is OnFailure) {
          DialogUtil().showMessage(state.errorMessage, context);
        } else if (state is RechargeSuccess) {
          DialogUtil().showMessage(
            context.bssSubL10n.rechargeSuccess,
            context,
            backgroundColor: AppColor.kSuccessGreen,
          );
        }
      },
      listenWhen: (previous, current) =>
          current is OnFailure || current is RechargeSuccess,
      buildWhen: (previous, current) =>
          current is GetDataSuccess || current is OnRecharging,
      builder: (context, state) {
        if (state is GetDataSuccess) {
          return Container(
            decoration: _sheetDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUserCard(state.entity),
                const SizedBox(height: 14),
                _buildDetailsCard(state.entity),
                const SizedBox(height: 22),
                _buildButtons(context),
              ],
            ),
          );
        } else if (state is OnRecharging) {
          return const Center(
            child: SizedBox(
              height: 45,
              width: 45,
              child: CircularProgressIndicator(
                color: AppColor.kPrimaryColor,
                strokeWidth: 3,
              ),
            ),
          );
        }
        return AppShimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: double.infinity, height: 140.h),
              const SizedBox(height: 30),
              ShimmerBox(width: double.infinity, height: 203.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(OfflineRechargeDataEntity entity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration,
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40.w,
                height: 40.h,
                decoration: _avatarDecoration,
                child: Center(
                  child: Text('🧔', style: _emojiStyle),
                ),
              ),
              const SizedBox(width: 12),
              // Name & sub
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.subscriberDetails.username,
                      style: _userNameStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entity.subscriberDetails.displayName,
                      style: _displayNameStyle,
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: _badgeDecoration,
                child: Text(
                  entity.rechargeDetails.subscriptionStatus,
                  style: _badgeTextStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColor.kWarmBackground, height: 1),
          const SizedBox(height: 12),

          // Stats row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: _statsDecoration,
            child: Row(
              children: [
                _StatItem(
                  label: context.bssSubL10n.lastPaid,
                  value: '₹${entity.subscriberDetails.lastTopUpAmount}',
                ),
                _StatItem(
                  label: context.bssSubL10n.rechargeCountLabel,
                  value: context.bssSubL10n.rechargeCountTimes(
                    entity.rechargeDetails.rechargeCount.toString(),
                  ),
                ),
                _StatItem(
                  label: context.bssSubL10n.lastPlan,
                  value: entity.rechargeDetails.lastPlan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(OfflineRechargeDataEntity entity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: _cardDecoration,
      child: Column(
        children: [
          _InfoRow(
            label: context.bssSubL10n.topupTo,
            value: entity.subscriberDetails.username,
          ),
          _InfoRow(
            label: context.bssSubL10n.topupAmount,
            value: '${entity.rechargeDetails.lastPaid}',
            valueColor: _orange,
            valueFontWeight: FontWeight.w600,
          ),
          _InfoRow(
            label: context.bssSubL10n.accountBalance,
            value: '${entity.rechargeDetails.accountBalance}',
          ),
          _InfoRow(
            label: context.bssSubL10n.topupMessage,
            value: entity.rechargeDetails.topUpMessage,
            valueStyle: const TextStyle(
              fontSize: 12,
              color: Color(0xFF555555),
              height: 1.5,
            ),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext ctx) {
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            label: ctx.bssSubL10n.no,
            onClicked: () => Navigator.pop(ctx),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: PrimaryButton(
            label: ctx.bssSubL10n.yes,
            isLoading: false,
            onClicked: () {
              Navigator.pop(ctx);
              DialogUtil().showMessage(
                ctx.bssSubL10n.rechargeCompletedSuccessfully,
                ctx,
                backgroundColor: AppColor.kSuccessGreen,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  // Sizer-based — computed once as static final.
  static final _labelStyle = TextStyle(
    fontSize: 8.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.30,
    color: const Color(0xFFAAAAAA),
  );
  static final _valueStyle = TextStyle(
    fontSize: 12.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    height: 1.30,
    color: AppColor.kRichBlack,
  );

  @override
  Widget build(BuildContext ctx) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 3),
          Text(value, style: _valueStyle),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? valueFontWeight;
  final TextStyle? valueStyle;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueFontWeight,
    this.valueStyle,
    this.isLast = false,
  });

  static final _labelStyle = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w400,
    height: 1.30,
    color: const Color(0xFF999999),
  );
  static final _defaultValueStyle = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'GeneralSans',
    height: 1.30,
    fontWeight: FontWeight.w500,
    color: AppColor.kRichBlack,
  );

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: valueStyle ??
                  (valueColor != null || valueFontWeight != null
                      ? _defaultValueStyle.copyWith(
                          color: valueColor,
                          fontWeight: valueFontWeight,
                        )
                      : _defaultValueStyle),
            ),
          ),
        ],
      ),
    );
  }
}
