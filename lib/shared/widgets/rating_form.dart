import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';

/// Label for a 1–5 star rating ("Excellent", …); empty for anything else.
String ratingLabelFor(BssSubLocalizations l10n, int rating) {
  return switch (rating) {
    1 => l10n.ratingVeryPoor,
    2 => l10n.ratingPoor,
    3 => l10n.ratingAverage,
    4 => l10n.ratingGood,
    5 => l10n.ratingExcellent,
    _ => '',
  };
}

/// Star picker, optional comment and submit button, shared by the ticket
/// rating card and the app feedback prompt. Holds the chosen rating and the
/// comment, so both survive a failed submission while [isLoading] toggles.
class RatingForm extends StatefulWidget {
  final bool isLoading;
  final String submitLabel;

  /// Called with the chosen rating (1–5) and the trimmed comment.
  final void Function(int rating, String comment) onSubmit;

  const RatingForm({
    super.key,
    required this.isLoading,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<RatingForm> createState() => _RatingFormState();
}

class _RatingFormState extends State<RatingForm> {
  static const _maxStars = 5;
  static const _commentMaxLength = 250;
  static const _starColor = AppColor.kGoldYellow;
  static const _starEmptyColor = AppColor.kShimmerBase;
  static const _animDuration = Duration(milliseconds: 250);

  final _commentController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) return;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSubmit(_rating, _commentController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    final isLoading = widget.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stars
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= _maxStars; i++)
              _AnimatedStar(
                filled: i <= _rating,
                selected: i == _rating,
                size: 40.w,
                filledColor: _starColor,
                emptyColor: _starEmptyColor,
                onTap: isLoading ? null : () => setState(() => _rating = i),
              ),
          ],
        ),
        SizedBox(height: 8.h),

        // Label for the chosen rating ("Excellent", …)
        Center(
          child: AnimatedSwitcher(
            duration: _animDuration,
            transitionBuilder:
                (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
            child: Text(
              _rating == 0 ? ' ' : ratingLabelFor(l10n, _rating),
              key: ValueKey(_rating),
              style: _ratingLabelStyle,
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Optional comment
        TextField(
          controller: _commentController,
          enabled: !isLoading,
          minLines: 3,
          maxLines: 3,
          maxLength: _commentMaxLength,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          style: _inputStyle,
          decoration: InputDecoration(
            hintText: l10n.ratingCommentHint,
            hintStyle: _hintStyle,
            filled: true,
            fillColor: AppColor.kSecondaryBackgroundColor,
            contentPadding: const EdgeInsets.all(12),
            border: _inputBorder,
            enabledBorder: _inputBorder,
            disabledBorder: _inputBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColor.kPrimaryColor),
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Disabled (faded) until a star is picked.
        AnimatedOpacity(
          duration: _animDuration,
          opacity: _rating == 0 ? 0.5 : 1,
          child: PrimaryButton(
            label: widget.submitLabel,
            height: 48.h,
            borderRadius: 10,
            isLoading: isLoading,
            onClicked: _rating == 0 || isLoading ? null : _submit,
          ),
        ),
      ],
    );
  }

  static final _ratingLabelStyle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColor.kDarkGoldenrod,
    fontFamily: 'GeneralSans',
  );
  static final _inputStyle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColor.kTextSecondaryDark,
    fontFamily: 'GeneralSans',
  );
  static final _hintStyle = TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.kMediumGrey,
    fontFamily: 'GeneralSans',
  );
  static const _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide.none,
  );
}

/// One tappable star: pops (scale bounce) when it becomes the selected one
/// and cross-fades between filled and outlined.
class _AnimatedStar extends StatelessWidget {
  final bool filled;
  final bool selected;
  final double size;
  final Color filledColor;
  final Color emptyColor;
  final VoidCallback? onTap;

  const _AnimatedStar({
    required this.filled,
    required this.selected,
    required this.size,
    required this.filledColor,
    required this.emptyColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: AnimatedScale(
          scale: selected ? 1.2 : 1,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              key: ValueKey(filled),
              size: size,
              color: filled ? filledColor : emptyColor,
            ),
          ),
        ),
      ),
    );
  }
}
