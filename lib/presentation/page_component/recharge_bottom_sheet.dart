import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';

class RechargeBottomSheet extends StatelessWidget {
  const RechargeBottomSheet({super.key});

  static const _bg = Color(0xFFEFEBE5);
  static const _orange = Color(0xFFE8820C);

  @override
  Widget build(BuildContext ctx) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUserCard(),
          const SizedBox(height: 14),

          // Details Card
          _buildDetailsCard(),
          const SizedBox(height: 22),

          // Buttons
          _buildButtons(ctx),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // User row
          Row(
            children: [
              // Avatar
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A4FA3), Color(0xFFA0522D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text('🧔', style: TextStyle(fontSize: 22.sp)),
                ),
              ),
              const SizedBox(width: 12),
              // Name & sub
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'kfon.Viswambl',
                      style: TextStyle(
                        fontSize: 16.sp,
                          fontFamily: 'General Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.30,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Savannah Nguyen',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Color(0xFF888888),
                          fontFamily: 'General Sans',
                          fontWeight: FontWeight.w500,
                          height: 1.30
                      ),
                    ),
                  ],
                ),
              ),
              // Expired badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE8EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Expired',
                  style: TextStyle(
                    fontSize: 10.sp,
                      fontFamily: 'General Sans',
                      fontWeight: FontWeight.w500,
                      height: 1.30,
                    color: Color(0xFFD0214A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFEFEBE5), height: 1),
          const SizedBox(height: 12),

          // Stats row
          Container(
            padding: EdgeInsets.all(12),
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
            Row(
              children: const [
                _StatItem(label: 'Last Paid', value: '₹499'),
                _StatItem(label: 'Recharge Count', value: '8 Times'),
                _StatItem(label: 'Last Plan', value: 'KFON_EWH_20Mbps'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Topup To', value: 'Sriharshablockedkyc01'),
          _InfoRow(
            label: 'Topup Amount',
            value: '499.54',
            valueColor: _orange,
            valueFontWeight: FontWeight.w600,
          ),
          _InfoRow(label: 'Account Balance', value: '60099.33'),
          _InfoRow(
            label: 'Topup Message',
            value:
                'Currently , the subscriber is Active. Once you top up , the recharge will be treated as an advance recharge',
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
        // No
        Expanded(
          child: SecondaryButton(
            label: 'No',
            onClicked: () => Navigator.pop(ctx),
          ),
        ),
        const SizedBox(width: 14),
        // Yes
        Expanded(
          child: PrimaryButton(
            label: 'Yes',
            isLoading: false,
            onClicked: () {
              Navigator.pop(ctx);
              DialogUtil().showMessage(
                'Your recharge has been completed Successfully',
                ctx,
                backgroundColor: Colors.green,
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

  @override
  Widget build(BuildContext ctx) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:  TextStyle(fontSize: 8.sp,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w400,
                height: 1.30,
                color: Color(0xFFAAAAAA)),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w500,
              height: 1.30,
              color: Color(0xFF1A1A1A),
            ),
          ),
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

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:  TextStyle(fontSize: 14.sp,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w400,
                height: 1.30,
                color: Color(0xFF999999)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style:
                  valueStyle ??
                  TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'General Sans',
                    height: 1.30,
                    fontWeight: valueFontWeight ?? FontWeight.w500,
                    color: valueColor ?? const Color(0xFF1A1A1A),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
