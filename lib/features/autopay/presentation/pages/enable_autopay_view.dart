import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';
import 'package:kfon_subscriber/features/autopay/presentation/widgets/autopay_widgets.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown when Autopay is not enabled: charge summary, UPI ID entry and
/// policies. [onSubmit] is called with the entered UPI ID.
class EnableAutopayView extends StatefulWidget {
  const EnableAutopayView({
    super.key,
    required this.quote,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final AutopayQuoteEntity quote;
  final bool isSubmitting;
  final ValueChanged<String> onSubmit;

  @override
  State<EnableAutopayView> createState() => _EnableAutopayViewState();
}

class _EnableAutopayViewState extends State<EnableAutopayView> {
  /// Used when the quote doesn't send `content.upiHandles`.
  static const _defaultUpiHandles = [
    '@okaxis',
    '@okhdfcbank',
    '@ybl',
    '@paytm',
  ];

  List<String> get _upiHandles =>
      widget.quote.upiHandles.isNotEmpty
          ? widget.quote.upiHandles
          : _defaultUpiHandles;

  /// name@handle — letters, digits, dot, hyphen, underscore before the @.
  static final _upiPattern = RegExp(r'^[\w.\-]{2,256}@[a-zA-Z]{2,64}$');

  final _upiController = TextEditingController();
  late final _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
  bool _agreed = false;
  bool _showUpiError = false;

  String get _upiId => _upiController.text.trim();
  bool get _isUpiValid => _upiPattern.hasMatch(_upiId);

  bool get _canSubmit =>
      widget.quote.eligible && _isUpiValid && _agreed && !widget.isSubmitting;

  @override
  void initState() {
    super.initState();
    _upiController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _upiController.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  void _applyHandle(String handle) {
    final text = _upiController.text.trim();
    final at = text.indexOf('@');
    final name = at >= 0 ? text.substring(0, at) : text;
    final value = '$name$handle';
    _upiController.value = TextEditingValue(
      text: value,
      // Leave the cursor before the handle so the name can be typed.
      selection: TextSelection.collapsed(offset: name.length),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _showUpiError = !_isUpiValid);
    if (_canSubmit) widget.onSubmit(_upiId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final eligible = widget.quote.eligible;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
            children: [
              AutopayInfoBanner(text: widget.quote.enrollmentBanner),
              if (!eligible) ...[
                SizedBox(height: 12.h),
                _buildIneligibleNotice(),
              ],
              SizedBox(height: 16.h),
              _buildChargeSummary(),
              SizedBox(height: 16.h),
              _buildSetUpCard(enabled: eligible),
              SizedBox(height: 16.h),
              _buildPolicies(),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
          child: PrimaryButton(
            label: l10n.process,
            isLoading: widget.isSubmitting,
            onClicked: _canSubmit ? _submit : null,
          ),
        ),
      ],
    );
  }

  Widget _buildIneligibleNotice() {
    final reason = widget.quote.ineligibleReason;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.kCreamYellowBg,
        border: Border.all(color: AppColor.kLightAmber),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18.sp, color: AppColor.kAmberDark),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              (reason != null && reason.trim().isNotEmpty)
                  ? reason
                  : context.bssSubL10n.autopayNotEligible,
              style: autopayText(
                12,
                FontWeight.w500,
                AppColor.kAmberBrown,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargeSummary() {
    final l10n = context.bssSubL10n;
    final quote = widget.quote;
    final labelStyle = autopayText(
      12,
      FontWeight.w400,
      AppColor.kStone600,
      height: 1.33,
    );
    final valueStyle = autopayText(
      12,
      FontWeight.w600,
      AppColor.kStone800,
      height: 1.33,
    );

    return AutopayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chargeSummary,
            style: autopayText(
              16,
              FontWeight.w600,
              AppColor.kTextSecondaryDark,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColor.kPlanCardGradientStart,
                  AppColor.kPlanCardGradientEnd,
                ],
              ),
              border: Border.all(color: AppColor.kPlanCardBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _summaryRow(
                  Text(l10n.renewalChargeInclGst, style: labelStyle),
                  Text(
                    formatAutopayAmount(quote.renewalFee),
                    style: valueStyle,
                  ),
                ),
                SizedBox(height: 10.h),
                _summaryRow(
                  Text(l10n.platformChargeInclGst, style: labelStyle),
                  Text(
                    formatAutopayAmount(quote.serviceCharge),
                    style: valueStyle,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.only(top: 8.h),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColor.kPlanCardDivider),
                    ),
                  ),
                  child: _summaryRow(
                    Text(
                      l10n.totalRenewalCharge,
                      style: autopayText(
                        12,
                        FontWeight.w600,
                        AppColor.kStone800,
                        height: 1.67,
                      ),
                    ),
                    Text(
                      formatAutopayAmount(quote.totalCharge),
                      style: autopayText(
                        14,
                        FontWeight.w600,
                        AppColor.kPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(Widget label, Widget value) =>
      Row(children: [Expanded(child: label), SizedBox(width: 8.w), value]);

  Widget _buildSetUpCard({required bool enabled}) {
    final l10n = context.bssSubL10n;
    final showError = _showUpiError && _upiId.isNotEmpty && !_isUpiValid;

    return AutopayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setUpAutopay,
            style: autopayText(
              16,
              FontWeight.w600,
              AppColor.kTextSecondaryDark,
              height: 1.3,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.enterUpiId,
            style: autopayText(
              14,
              FontWeight.w500,
              AppColor.kStone700,
              height: 1.14,
            ),
          ),
          SizedBox(height: 6.h),
          TextField(
            controller: _upiController,
            enabled: enabled && !widget.isSubmitting,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: autopayText(14, FontWeight.w500, AppColor.kStone900),
            decoration: InputDecoration(
              hintText: l10n.upiIdHint,
              hintStyle: autopayText(14, FontWeight.w500, AppColor.kStone400),
              errorText: showError ? l10n.invalidUpiId : null,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: AutopayUpiTag(),
              ),
              suffixIconConstraints: const BoxConstraints(),
              enabledBorder: _inputBorder(AppColor.kStone300),
              disabledBorder: _inputBorder(AppColor.kStone200),
              focusedBorder: _inputBorder(AppColor.kPrimaryColor),
              errorBorder: _inputBorder(AppColor.kErrorRed),
              focusedErrorBorder: _inputBorder(AppColor.kErrorRed),
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              for (final handle in _upiHandles)
                InkWell(
                  onTap: enabled ? () => _applyHandle(handle) : null,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.kStone100,
                      border: Border.all(color: AppColor.kStone200),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      handle,
                      style: autopayText(
                        11,
                        FontWeight.w500,
                        AppColor.kStone600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildAgreement(enabled: enabled),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color),
  );

  Widget _buildAgreement({required bool enabled}) {
    final l10n = context.bssSubL10n;
    final primary = AppColor.kPrimaryColor;
    final style = autopayText(12, FontWeight.w400, AppColor.kStone700);

    return InkWell(
      onTap:
          enabled && !widget.isSubmitting
              ? () => setState(() => _agreed = !_agreed)
              : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColor.kNeutralBgAlpha70,
          border: Border.all(color: AppColor.kStone300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                color: _agreed ? primary : Colors.white,
                border: Border.all(
                  color: _agreed ? primary : AppColor.kStone300,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child:
                  _agreed
                      ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                      : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: style,
                  children: [
                    TextSpan(text: '${l10n.autopayAgreePrefix} '),
                    TextSpan(
                      text: l10n.termsAndConditionsTitle,
                      recognizer: _termsRecognizer,
                      style: style.copyWith(
                        color: primary,
                        decoration: TextDecoration.underline,
                        decorationColor: primary,
                      ),
                    ),
                    TextSpan(text: ' ${l10n.autopayAgreeMiddle} '),
                    TextSpan(
                      text: formatAutopayAmount(widget.quote.totalCharge),
                      style: style.copyWith(
                        color: AppColor.kStone900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' ${l10n.autopayAgreeSuffix}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicies() {
    final l10n = context.bssSubL10n;
    final bodyStyle = autopayText(
      11,
      FontWeight.w400,
      AppColor.kStone700,
      height: 1.63,
    );
    final platformPolicy = widget.quote.platformChargePolicy?.trim() ?? '';
    final apiTollFree = widget.quote.tollFreeNumber?.trim() ?? '';
    final tollFree = apiTollFree.isNotEmpty ? apiTollFree : l10n.tollFreeNumber;

    return AutopayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _policySection(
            l10n.platformChargePolicy,
            Text(
              platformPolicy.isNotEmpty
                  ? platformPolicy
                  : l10n.platformChargePolicyText,
              style: bodyStyle,
            ),
          ),
          _policyDivider(),
          _policySection(
            l10n.refundCancellationPolicy,
            Text(
              (widget.quote.refundPolicy?.trim().isNotEmpty ?? false)
                  ? widget.quote.refundPolicy!.trim()
                  : l10n.refundCancellationPolicyText,
              style: bodyStyle,
            ),
          ),
          _policyDivider(),
          _policySection(
            l10n.contactUs,
            GestureDetector(
              onTap: () => _callSupport(tollFree),
              child: Text.rich(
                TextSpan(
                  style: bodyStyle,
                  children: [
                    TextSpan(text: '${l10n.contactUsPrefix} '),
                    TextSpan(
                      text: tollFree,
                      style: bodyStyle.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ', ${l10n.contactUsSuffix}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _policySection(String title, Widget body) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: autopayText(
          14,
          FontWeight.w500,
          AppColor.kTextSecondaryDark,
          height: 1.3,
        ),
      ),
      SizedBox(height: 6.h),
      body,
    ],
  );

  Widget _policyDivider() => Padding(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    child: const Divider(height: 1, thickness: 1, color: AppColor.kStone100),
  );

  Future<void> _openTerms() async {
    final uri = Uri.tryParse(widget.quote.termsUrl?.trim() ?? '');
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callSupport(String number) async {
    final uri = Uri(scheme: 'tel', path: number.replaceAll(' ', ''));
    await launchUrl(uri);
  }
}
