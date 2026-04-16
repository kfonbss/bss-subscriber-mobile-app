import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/top_up/domain/repository/topup_repository.dart';
import 'package:kfon_subscriber/features/top_up/presentation/bloc/topup_bloc.dart';
import 'package:kfon_subscriber/features/top_up/presentation/bloc/topup_event.dart';
import 'package:kfon_subscriber/features/top_up/presentation/bloc/topup_state.dart';
import 'package:kfon_subscriber/features/top_up/presentation/pages/payment_webview_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/painter/dashed_line_painter.dart';
import 'package:kfon_subscriber/service_locator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Layout constants — single source of truth consumed by all child widgets.
// Centralising them here prevents magic numbers from being scattered across
// multiple build() methods.
// ─────────────────────────────────────────────────────────────────────────────
class _TopupLayout {
  _TopupLayout._();
  static const double headerHeight = 191.0;
  static const double appBarTop = 68.0;
  static const double cardTop = 134.0;
  static const double cardHeight = 86.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — provides the BLoC above the stateful subtree so that
// context.read<TopupBloc>() is available to all descendants without a Builder.
// ─────────────────────────────────────────────────────────────────────────────
class TopupPage extends StatelessWidget {
  const TopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopupBloc(repository: sl<TopupRepository>()),
      child: const _TopupView(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TopupView — the only StatefulWidget on this page.
//
// Its state has ONE job: manage objects that need disposal and own all BLoC
// side-effects (navigation, dialogs, snackbars).  No layout code lives here.
// The build() method is a thin wiring layer that passes controllers and
// callbacks down to purely presentational StatelessWidgets.
// ─────────────────────────────────────────────────────────────────────────────
class _TopupView extends StatefulWidget {
  const _TopupView();

  @override
  State<_TopupView> createState() => _TopupViewState();
}

class _TopupViewState extends State<_TopupView> {
  // ── Static data ─────────────────────────────────────────────────────────────
  static const List<int> _quickRechargeAmounts = [500, 750, 1000, 2000];
  static const List<PaymentGateway> _paymentGateways = [
    PaymentGateway(id: 'hdfc', name: 'HDFC', icon: 'assets/images/hdfc_logo.png'),
    PaymentGateway(id: 'ikm', name: 'IKM', icon: 'assets/images/ikm_logo.png'),
  ];

  // RegExp + formatter list allocated once — not per-build.
  static final _amountRegExp = RegExp(r'^\d+\.?\d{0,2}');
  static final _inputFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(_amountRegExp),
  ];

  // Painter instance shared with _AmountEntryCard. Reusing the same instance
  // lets CustomPaint.shouldRepaint() short-circuit on every frame.
  static final _amountCardPainter = DashedLinePainter(
    color: const Color(0x33000000), // Colors.black.withValues(alpha: 0.20)
    strokeWidth: 1,
  );

  // ── Disposable state ─────────────────────────────────────────────────────────
  final TextEditingController _amountController = TextEditingController();

  // ValueNotifier instead of setState — gateway selection changes rebuild
  // only the scoped ValueListenableBuilder subtrees, not the whole page.
  final ValueNotifier<String?> _selectedGateway = ValueNotifier(null);

  // Guards Navigator.pop() calls that dismiss the loading dialog so they never
  // fire if TopupLoading was skipped (e.g. rapid state transitions).
  bool _isLoadingDialogOpen = false;

  // TODO: fetch wallet balance from API — placeholder value.
  final double _accountBalance = 30.00;

  @override
  void dispose() {
    _amountController.dispose();
    _selectedGateway.dispose();
    super.dispose();
  }

  // ── Business logic ───────────────────────────────────────────────────────────

  // TextEditingController notifies the TextField internally — no setState needed.
  void _selectQuickAmount(int amount) {
    _amountController.text = amount.toString();
  }

  void _processPayment() {
    final l10n = context.bssSubL10n;

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.pleaseEnterAnAmount),
        backgroundColor: AppColor.kFailedRed,
      ));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.pleaseEnterAValidAmount),
        backgroundColor: AppColor.kFailedRed,
      ));
      return;
    }

    final gateway = _selectedGateway.value;
    if (gateway == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.pleaseSelectAPaymentGateway),
        backgroundColor: AppColor.kFailedRed,
      ));
      return;
    }

    context.read<TopupBloc>().add(
      InitiateTopup(amount: amount, paymentType: gateway.toUpperCase()),
    );
  }

  // ── Navigation / dialog helpers ──────────────────────────────────────────────
  // Dialogs are extracted as proper StatelessWidgets (_TopupSuccessDialog,
  // _TopupFailedDialog). These methods are just the showDialog wrappers so
  // the calling BlocListener stays readable.

  void _showSuccessDialog(double amount, {String? transactionId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x80000000), // black @ 50% opacity
      builder: (dialogContext) => _TopupSuccessDialog(
        amount: amount,
        transactionId: transactionId,
        onDone: () {
          Navigator.pop(dialogContext);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFailedDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x80000000), // black @ 50% opacity
      builder: (dialogContext) => _TopupFailedDialog(
        amount: amount,
        onRetry: () => Navigator.pop(dialogContext),
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────────
  // The build method is intentionally thin — it only:
  //   1. Reads the two runtime values needed for layout (l10n, bottom inset).
  //   2. Attaches the BlocListener for side-effects.
  //   3. Wires controllers / callbacks into the presentational child widgets.
  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    // paddingOf is a narrower subscription than MediaQuery.of — only rebuilds
    // when the bottom inset changes (e.g. keyboard, notch).
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return BlocListener<TopupBloc, TopupState>(
      listener: (context, state) async {
        if (state is TopupLoading) {
          _isLoadingDialogOpen = true;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is TopupSuccess) {
          if (_isLoadingDialogOpen) {
            _isLoadingDialogOpen = false;
            Navigator.of(context).pop();
          }
          final result = await Navigator.push<PaymentResult>(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentWebViewPage(redirectEntity: state.redirectData),
            ),
          );
          if (context.mounted) {
            final bloc = context.read<TopupBloc>();
            final amount = double.tryParse(_amountController.text) ?? 0;
            switch (result) {
              case PaymentResult.success:
                bloc.add(OnPaymentCompleted(amount: amount));
                break;
              case PaymentResult.failed:
                bloc.add(const OnPaymentFailed());
                break;
              case PaymentResult.cancelled:
              case null:
                bloc.add(const OnPaymentCancelled());
                break;
            }
          }
        } else if (state is TopupError) {
          if (_isLoadingDialogOpen) {
            _isLoadingDialogOpen = false;
            Navigator.of(context).pop();
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: AppColor.kFailedRed,
          ));
        } else if (state is PaymentCompleted) {
          _showSuccessDialog(state.amount ?? 0, transactionId: state.transactionId);
        } else if (state is PaymentFailed) {
          _showFailedDialog(double.tryParse(_amountController.text) ?? 0);
        } else if (state is PaymentCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.paymentCancelled),
            backgroundColor: AppColor.kPendingOrange,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.kMainBackgroundColor,
        body: Stack(
          children: [
            // Each child widget owns its Positioned wrapper and its own static
            // decoration constants. _TopupViewState owns nothing presentational.
            const _TopupBackgroundSvg(),
            const _TopupAppBar(),
            Positioned(
              top: _TopupLayout.cardTop,
              left: 20,
              right: 20,
              child: _AmountEntryCard(
                controller: _amountController,
                inputFormatters: _inputFormatters,
                painter: _amountCardPainter,
                accountBalance: _accountBalance,
              ),
            ),
            Positioned(
              top: _TopupLayout.cardTop + _TopupLayout.cardHeight + 20,
              left: 0,
              right: 0,
              bottom: 34 + bottomPadding + 52 + 20,
              child: _TopupScrollBody(
                amounts: _quickRechargeAmounts,
                gateways: _paymentGateways,
                selectedGateway: _selectedGateway,
                onAmountSelected: _selectQuickAmount,
              ),
            ),
            Positioned(
              bottom: 34 + bottomPadding,
              left: 20,
              right: 20,
              child: _PayButton(
                selectedGateway: _selectedGateway,
                onPressed: _processPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Presentational widgets — StatelessWidget, no BLoC references, no state.
// Each owns the static decoration constants relevant to itself.
// ─────────────────────────────────────────────────────────────────────────────

/// Full-width SVG banner that spans the top of the page.
/// Returns a [Positioned] so it self-positions inside the parent [Stack].
class _TopupBackgroundSvg extends StatelessWidget {
  const _TopupBackgroundSvg();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: _TopupLayout.headerHeight,
      child: SvgPicture.asset(
        'assets/images/speed_test_background.svg',
        fit: BoxFit.cover,
      ),
    );
  }
}

/// Custom app bar: back button on the left, localised title centred.
/// Returns a [Positioned] so it self-positions inside the parent [Stack].
class _TopupAppBar extends StatelessWidget {
  const _TopupAppBar();

  // 0x4DFFFFFF == Colors.white.withValues(alpha: 0.3)
  static const _backButtonDecoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.fromBorderSide(BorderSide(color: Color(0x4DFFFFFF))),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return Positioned(
      top: _TopupLayout.appBarTop,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              child: Container(
                decoration: _backButtonDecoration,
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            Expanded(
              child: Text(
                l10n.amountTopUp,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  fontFamily: 'GeneralSans',
                ),
              ),
            ),
            // Balances the back button so the title stays centred.
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}

/// White card that holds the rupee-prefixed [TextField] and the account balance.
/// Receives the [controller] and [painter] from [_TopupViewState] so it has
/// no lifecycle responsibilities of its own.
class _AmountEntryCard extends StatelessWidget {
  final TextEditingController controller;
  final List<TextInputFormatter> inputFormatters;
  final CustomPainter painter;
  final double accountBalance;

  const _AmountEntryCard({
    required this.controller,
    required this.inputFormatters,
    required this.painter,
    required this.accountBalance,
  });

  static const _decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: AppColor.kCardShadow,
        blurRadius: 16,
        offset: Offset.zero,
        spreadRadius: 0,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return Container(
      height: _TopupLayout.cardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 13.54, vertical: 19),
      decoration: _decoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '₹',
                style: TextStyle(
                  color: AppColor.kDarkCharcoal,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 0.92,
                  fontFamily: 'GeneralSans',
                ),
              ),
              IntrinsicWidth(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: inputFormatters,
                  decoration: InputDecoration(
                    hintText: l10n.enterAmount,
                    hintStyle: const TextStyle(
                      color: AppColor.kDarkCharcoal,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 0.92,
                      fontFamily: 'GeneralSans',
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    color: AppColor.kDarkCharcoal,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 0.92,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: painter),
          ),
          const SizedBox(height: 5),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: l10n.accountBalanceLabel,
                  style: const TextStyle(
                    color: AppColor.kBodyTextGrey,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: '₹${accountBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColor.kPrimaryColor,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Scrollable area containing quick-recharge chips and payment gateway tiles.
/// Pure display widget — all interaction is surfaced via callbacks.
class _TopupScrollBody extends StatelessWidget {
  final List<int> amounts;
  final List<PaymentGateway> gateways;
  final ValueNotifier<String?> selectedGateway;
  final ValueChanged<int> onAmountSelected;

  const _TopupScrollBody({
    required this.amounts,
    required this.gateways,
    required this.selectedGateway,
    required this.onAmountSelected,
  });

  // 0x1A000000 == Colors.black.withValues(alpha: 0.1)
  static const _chipBorderRadius = BorderRadius.all(Radius.circular(130));
  static const _chipDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(130)),
    border: Border.fromBorderSide(BorderSide(color: Color(0x1A000000))),
  );
  static const _sectionTitleStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    fontFamily: 'GeneralSans',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.quickRecharge, style: _sectionTitleStyle),
          const SizedBox(height: 16),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: amounts
                .map(
                  (amount) => InkWell(
                    onTap: () => onAmountSelected(amount),
                    borderRadius: _chipBorderRadius,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: _chipDecoration,
                      child: Text(
                        '+$amount',
                        style: const TextStyle(
                          color: AppColor.kPrimaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text(l10n.selectPaymentGateway, style: _sectionTitleStyle),
          const SizedBox(height: 20),
          // Each _GatewayTile owns a scoped ValueListenableBuilder — only the
          // radio indicator inside it rebuilds on selection change.
          ...gateways.map(
            (gw) => _GatewayTile(gateway: gw, selectedGateway: selectedGateway),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Process-to-Pay button that enables/disables based on gateway selection.
/// Uses [ValueListenableBuilder] so only this widget rebuilds on selection
/// change — not the parent [_TopupViewState].
class _PayButton extends StatelessWidget {
  final ValueNotifier<String?> selectedGateway;
  final VoidCallback onPressed;

  const _PayButton({
    required this.selectedGateway,
    required this.onPressed,
  });

  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  // ElevatedButton.styleFrom allocates a new ButtonStyle on every builder call.
  // Hoisting two static finals means the style object is created once each.
  static final _selectedStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColor.kPrimaryColor,
    shape: _buttonShape,
    padding: const EdgeInsets.symmetric(vertical: 15),
  );
  static final _disabledStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColor.kMediumGrey,
    disabledBackgroundColor: AppColor.kMediumGrey,
    shape: _buttonShape,
    padding: const EdgeInsets.symmetric(vertical: 15),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return ValueListenableBuilder<String?>(
      valueListenable: selectedGateway,
      // Stable child — Text is never rebuilt on gateway selection change.
      child: Text(
        l10n.processToPay,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.3,
          fontFamily: 'GeneralSans',
        ),
      ),
      builder: (context, selected, child) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: selected != null ? onPressed : null,
            style: selected != null ? _selectedStyle : _disabledStyle,
            child: child,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog widgets — fully self-contained StatelessWidgets.
// _TopupViewState calls showDialog and passes an onDone/onRetry callback;
// navigation is the caller's responsibility (not hardcoded here).
// ─────────────────────────────────────────────────────────────────────────────

class _TopupSuccessDialog extends StatelessWidget {
  final double amount;
  final String? transactionId;
  final VoidCallback onDone;

  const _TopupSuccessDialog({
    required this.amount,
    required this.onDone,
    this.transactionId,
  });

  static const _containerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: _containerDecoration,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/top-up_successfull.svg',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 26),
            Text(
              l10n.topUpSuccessful,
              style: const TextStyle(
                color: AppColor.kTextSecondaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
                fontFamily: 'GeneralSans',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.topUpSuccessMessage,
              style: const TextStyle(
                color: AppColor.kDarkBlue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.54,
                fontFamily: 'GeneralSans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColor.kSecondaryBackgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Column(
                children: [
                  if (transactionId != null && transactionId!.isNotEmpty) ...[
                    _DetailRow(label: l10n.bssReference, value: transactionId!),
                    const SizedBox(height: 14),
                  ],
                  _DetailRow(
                    label: l10n.paymentAmountRs,
                    value: amount.toStringAsFixed(2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.topUpNote,
              style: const TextStyle(
                color: AppColor.kMediumGrey,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.82,
                fontFamily: 'GeneralSans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.kPrimaryColor,
                  shape: _buttonShape,
                ),
                child: Text(
                  l10n.ok,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopupFailedDialog extends StatelessWidget {
  final double amount;
  final VoidCallback onRetry;

  const _TopupFailedDialog({
    required this.amount,
    required this.onRetry,
  });

  static const _containerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20)),
  );
  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  // 0x1A000000 == Colors.black.withValues(alpha: 0.10)
  static final _dashedPainter = DashedLinePainter(
    color: const Color(0x1A000000),
    strokeWidth: 1,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: _containerDecoration,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 27),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/top-up_fail.svg',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 26),
            Text(
              l10n.topUpFailed,
              style: const TextStyle(
                color: AppColor.kTextSecondaryDark,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.3,
                fontFamily: 'GeneralSans',
              ),
            ),
            const SizedBox(height: 13),
            Text(
              l10n.topUpFailedMessage(amount.toStringAsFixed(2)),
              style: const TextStyle(
                color: AppColor.kDarkBlue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.54,
                fontFamily: 'GeneralSans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Text(
              l10n.topUpFailedRetryMessage,
              style: const TextStyle(
                color: AppColor.kDarkBlue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.54,
                fontFamily: 'GeneralSans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: 222,
              height: 1,
              child: CustomPaint(painter: _dashedPainter),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.kPrimaryColor,
                  shape: _buttonShape,
                ),
                child: Text(
                  l10n.retry,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A label-value row used in payment detail containers.
/// Extracted from [_TopupViewState._buildDetailRow] as a proper widget so it
/// can be used in both dialog widgets without coupling them to the state.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColor.kTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.3,
              fontFamily: 'GeneralSans',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: const TextStyle(
            color: AppColor.kNearBlack,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.3,
            fontFamily: 'GeneralSans',
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gateway tile and radio indicators
// ─────────────────────────────────────────────────────────────────────────────

/// A single selectable payment gateway row.
/// Uses [ValueListenableBuilder] scoped to [selectedGateway] so that only the
/// radio indicator and border rebuild on selection change — the logo and name
/// are passed as the stable [ValueListenableBuilder.child] and are never
/// rebuilt by the listener.
class _GatewayTile extends StatelessWidget {
  final PaymentGateway gateway;
  final ValueNotifier<String?> selectedGateway;

  const _GatewayTile({
    required this.gateway,
    required this.selectedGateway,
  });

  static const _logoDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(8)),
    // 0x14000000 == Colors.black.withValues(alpha: ~0.08)
    border: Border.fromBorderSide(BorderSide(color: Color(0x14000000))),
  );
  static const _tileInkRadius = BorderRadius.all(Radius.circular(12));
  static const _selectedTileDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kPrimaryColor, width: 1.5),
    ),
  );
  static const _unselectedTileDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    border: Border.fromBorderSide(BorderSide(color: Color(0x14000000))),
  );

  @override
  Widget build(BuildContext context) {
    final logoAndName = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(6),
          decoration: _logoDecoration,
          child: Image.asset(
            gateway.icon,
            cacheWidth: 72,
            cacheHeight: 72,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          gateway.name,
          style: const TextStyle(
            color: AppColor.kTextSecondaryDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'GeneralSans',
          ),
        ),
      ],
    );

    return ValueListenableBuilder<String?>(
      valueListenable: selectedGateway,
      child: logoAndName,
      builder: (context, selected, child) {
        final isSelected = selected == gateway.id;
        return InkWell(
          onTap: () => selectedGateway.value = gateway.id,
          borderRadius: _tileInkRadius,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: isSelected
                ? _selectedTileDecoration
                : _unselectedTileDecoration,
            child: Row(
              children: [
                Expanded(child: child!),
                isSelected ? const _RadioSelected() : const _RadioUnselected(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RadioSelected extends StatelessWidget {
  const _RadioSelected();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.kPrimaryColor,
      ),
      child: const Icon(Icons.check_rounded, size: 13, color: Colors.white),
    );
  }
}

class _RadioUnselected extends StatelessWidget {
  const _RadioUnselected();

  // Border.all() is not const; Border.fromBorderSide() is.
  static const _decoration = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.fromBorderSide(
      BorderSide(color: Color(0x33000000), width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: _decoration,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable value object describing a payment gateway option.
/// const constructor allows use in [static const] collections.
class PaymentGateway {
  final String id;
  final String name;
  final String icon;

  const PaymentGateway({
    required this.id,
    required this.name,
    required this.icon,
  });
}
