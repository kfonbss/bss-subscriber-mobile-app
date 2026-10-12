import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/ticket/data/model/rate_ticket_req.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_bloc.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/rating_form.dart';

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
  static const _starColor = AppColor.kGoldYellow;
  static const _starEmptyColor = AppColor.kShimmerBase;

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

  void _submit(int rating, String comment) {
    widget.ticketBloc.add(
      OnRateTicket(
        params: RateTicketReq(
          ticketUuid: widget.ticketUuid,
          rating: rating,
          comment: comment,
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
        RatingForm(
          isLoading: isLoading,
          submitLabel: l10n.submitRating,
          onSubmit: _submit,
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
        Text(ratingLabelFor(l10n, rating), style: _ratingLabelStyle),
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
}
