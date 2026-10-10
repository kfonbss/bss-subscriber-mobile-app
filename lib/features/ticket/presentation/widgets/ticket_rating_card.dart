import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/ticket/data/model/rate_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/l10n/bss_sub_localizations.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';

/// "Rate your experience" card on the ticket detail page.
///
/// Pick 1–5 stars (each tap pops the star and updates the label), add an
/// optional comment and submit. Once rated — now or earlier, via
/// [initialRating] — the card switches to a read-only thank-you view.
class TicketRatingCard extends StatefulWidget {
  final String ticketUuid;
  final TicketBloc ticketBloc;
  final int? initialRating;
  final String? initialComment;

  const TicketRatingCard({
    super.key,
    required this.ticketUuid,
    required this.ticketBloc,
    this.initialRating,
    this.initialComment,
  });

  @override
  State<TicketRatingCard> createState() => _TicketRatingCardState();
}

class _TicketRatingCardState extends State<TicketRatingCard> {
  static const _maxStars = 5;
  static const _commentMaxLength = 250;
  static const _starColor = AppColor.kGoldYellow;
  static const _starEmptyColor = AppColor.kShimmerBase;
  static const _animDuration = Duration(milliseconds: 250);

  final _commentController = TextEditingController();
  int _rating = 0;

  /// Set once the ticket has a rating; the card is then read-only.
  int? _submittedRating;
  String _submittedComment = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRating;
    if (initial != null && initial > 0) {
      _submittedRating = initial.clamp(1, _maxStars);
      _submittedComment = widget.initialComment?.trim() ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _ratingLabel(BssSubLocalizations l10n, int rating) {
    return switch (rating) {
      1 => l10n.ratingVeryPoor,
      2 => l10n.ratingPoor,
      3 => l10n.ratingAverage,
      4 => l10n.ratingGood,
      5 => l10n.ratingExcellent,
      _ => '',
    };
  }

  void _submit() {
    if (_rating == 0) return;
    FocusManager.instance.primaryFocus?.unfocus();
    widget.ticketBloc.add(
      OnRateTicket(
        params: RateTicketReq(
          ticketUuid: widget.ticketUuid,
          rating: _rating,
          comment: _commentController.text.trim(),
        ),
      ),
    );
  }

  static const _cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [BoxShadow(color: AppColor.kCardShadow, blurRadius: 16)],
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TicketBloc, TicketState>(
      bloc: widget.ticketBloc,
      listenWhen: (_, current) => current is RatingSubmitted,
      listener: (context, state) {
        if (state is RatingSubmitted) {
          setState(() {
            _submittedRating = state.rating;
            _submittedComment = state.comment;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.bssSubL10n.ratingSubmitted)),
          );
        }
      },
      buildWhen:
          (previous, current) =>
              current is RatingSubmitting ||
              previous is RatingSubmitting ||
              current is RatingSubmitted,
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: _cardDecoration,
          // Cross-fade between the form and the thank-you view.
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                _submittedRating != null
                    ? _buildSubmitted(context, _submittedRating!)
                    : _buildForm(context, isLoading: state is RatingSubmitting),
          ),
        );
      },
    );
  }

  // ── Form ────────────────────────────────────────────────────────────────
  Widget _buildForm(BuildContext context, {required bool isLoading}) {
    final l10n = context.bssSubL10n;

    return Column(
      key: const ValueKey('rating-form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.rateYourExperience, style: _titleStyle),
        SizedBox(height: 4.h),
        Text(l10n.rateTicketSubtitle, style: _subtitleStyle),
        SizedBox(height: 16.h),

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
              _rating == 0 ? ' ' : _ratingLabel(l10n, _rating),
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
            label: l10n.submitRating,
            height: 48.h,
            borderRadius: 10,
            isLoading: isLoading,
            onClicked: _rating == 0 || isLoading ? null : _submit,
          ),
        ),
      ],
    );
  }

  // ── Submitted (read-only) ────────────────────────────────────────────────
  Widget _buildSubmitted(BuildContext context, int rating) {
    final l10n = context.bssSubL10n;

    return Column(
      key: const ValueKey('rating-submitted'),
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: AppColor.kActiveGreen10,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColor.kActiveGreen,
            size: 28.w,
          ),
        ),
        SizedBox(height: 12.h),
        Text(l10n.thanksForFeedback, style: _titleStyle),
        SizedBox(height: 12.h),
        Text(l10n.yourRating, style: _subtitleStyle),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 1; i <= _maxStars; i++)
              Icon(
                Icons.star_rounded,
                size: 28.w,
                color: i <= rating ? _starColor : _starEmptyColor,
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(_ratingLabel(l10n, rating), style: _ratingLabelStyle),
        if (_submittedComment.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColor.kSecondaryBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Text(_submittedComment, style: _inputStyle),
          ),
        ],
      ],
    );
  }

  // ── Styles ──────────────────────────────────────────────────────────────
  static final _titleStyle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColor.kTextSecondaryDark,
    fontFamily: 'GeneralSans',
  );
  static final _subtitleStyle = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColor.kLabelGrey,
    fontFamily: 'GeneralSans',
  );
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
