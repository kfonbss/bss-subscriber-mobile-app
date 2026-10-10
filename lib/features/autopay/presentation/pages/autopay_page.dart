import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/features/autopay/domain/repository/autopay_repository.dart';
import 'package:kfon_subscriber/features/autopay/presentation/bloc/autopay_bloc.dart';
import 'package:kfon_subscriber/features/autopay/presentation/bloc/autopay_event.dart';
import 'package:kfon_subscriber/features/autopay/presentation/bloc/autopay_state.dart';
import 'package:kfon_subscriber/features/autopay/presentation/pages/autopay_details_view.dart';
import 'package:kfon_subscriber/features/autopay/presentation/pages/enable_autopay_view.dart';
import 'package:kfon_subscriber/features/autopay/presentation/widgets/autopay_remove_bottom_sheet.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';

/// Auto Pay entry screen. Checks the mandate status and shows either the
/// details screen (ACTIVE / PENDING) or the enable screen.
///
/// Open it with:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const AutopayPage()));
/// ```
class AutopayPage extends StatelessWidget {
  const AutopayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              AutopayBloc(repository: sl<AutopayRepository>())
                ..add(const LoadAutopay()),
      child: const _AutopayView(),
    );
  }
}

class _AutopayView extends StatelessWidget {
  const _AutopayView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      title: l10n.autoPay,
      scaffoldColor: AppColor.kMainBackgroundColor,
      onBackPressed: () => Navigator.of(context).pop(),
      body: BlocConsumer<AutopayBloc, AutopayState>(
        listenWhen: (previous, current) => previous.action != current.action,
        listener: _onAction,
        builder: (context, state) {
          switch (state.viewStatus) {
            case AutopayViewStatus.initial:
            case AutopayViewStatus.loading:
              return const ListShimmer(itemCount: 3, itemHeight: 160);
            case AutopayViewStatus.error:
              return RetryWidget(
                errorMessage: state.message ?? l10n.somethingWentWrong,
                onRetry:
                    () => context.read<AutopayBloc>().add(const LoadAutopay()),
              );
            case AutopayViewStatus.loaded:
              final details = state.details;
              if (state.autopayStatus.isEnabled && details != null) {
                return AutopayDetailsView(
                  details: details,
                  status: state.autopayStatus,
                  bannerText: state.quote?.enrollmentBanner,
                  onRemove:
                      () => AutopayRemoveBottomSheet.show(
                        context,
                        details: details,
                      ),
                );
              }
              final quote = state.quote;
              if (quote == null) return const SizedBox.shrink();
              return EnableAutopayView(
                quote: quote,
                isSubmitting: state.isInitiating,
                onSubmit:
                    (upiId) => context.read<AutopayBloc>().add(
                      InitiateAutopay(upiId: upiId),
                    ),
              );
          }
        },
      ),
    );
  }

  void _onAction(BuildContext context, AutopayState state) {
    final l10n = context.bssSubL10n;
    final message = state.message?.trim() ?? '';
    final dialog = DialogUtil();

    switch (state.action) {
      case AutopayAction.initiateSuccess:
        dialog.showCustomSnackbar(
          context: context,
          content: message.isNotEmpty ? message : l10n.autopayRequestSent,
          backgroundColor: AppColor.kCompletedGreen,
        );
      case AutopayAction.revokeSuccess:
        dialog.showCustomSnackbar(
          context: context,
          content: message.isNotEmpty ? message : l10n.autopayRemoved,
          backgroundColor: AppColor.kCompletedGreen,
        );
      case AutopayAction.initiateFailure:
      case AutopayAction.revokeFailure:
        dialog.showCustomSnackbar(
          context: context,
          content: message.isNotEmpty ? message : l10n.somethingWentWrong,
          backgroundColor: AppColor.kSuspendedStatusText,
        );
      case AutopayAction.none:
      case AutopayAction.initiating:
      case AutopayAction.revoking:
        break;
    }
  }
}
