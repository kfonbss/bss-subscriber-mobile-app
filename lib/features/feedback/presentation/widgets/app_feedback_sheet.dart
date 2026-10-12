import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/feedback/presentation/bloc/feedback_cubit.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';
import 'package:kfon_subscriber/shared/widgets/rating_form.dart';

/// Shows the app feedback sheet. Resolves to `true` when feedback was
/// submitted successfully, otherwise (dismissed) `null`.
///
/// Only one sheet can be open at a time; a second call returns `null`.
bool _feedbackSheetOpen = false;

Future<bool?> showAppFeedbackSheet(BuildContext context) async {
  if (_feedbackSheetOpen) return null;
  _feedbackSheetOpen = true;
  try {
    return await showAppModalBottomSheet<bool>(
      context: context,
      builder: (_) => const AppFeedbackSheet(),
    );
  } finally {
    _feedbackSheetOpen = false;
  }
}

class AppFeedbackSheet extends StatelessWidget {
  const AppFeedbackSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedbackCubit(),
      child: BlocConsumer<FeedbackCubit, FeedbackState>(
        listener: (context, state) {
          final l10n = context.bssSubL10n;
          if (state is FeedbackSubmitted) {
            DialogUtil().showCustomSnackbar(
              context: context,
              content: l10n.ratingSubmitted,
            );
            Navigator.of(context).pop(true);
          } else if (state is FeedbackFailed) {
            DialogUtil().showCustomSnackbar(
              context: context,
              content: state.message,
              isError: true,
            );
          }
        },
        builder: (context, state) {
          final l10n = context.bssSubL10n;
          final isLoading = state is FeedbackSubmitting;
          return PopScope(
            canPop: !isLoading,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                0,
                20.w,
                20.h + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.rateYourExperience, style: _titleStyle),
                  SizedBox(height: 4.h),
                  Text(l10n.rateAppSubtitle, style: _subtitleStyle),
                  SizedBox(height: 16.h),
                  RatingForm(
                    isLoading: isLoading,
                    submitLabel: l10n.submitRating,
                    onSubmit:
                        (rating, comment) => context
                            .read<FeedbackCubit>()
                            .submit(rating, comment),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
}
