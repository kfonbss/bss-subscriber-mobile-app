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
import 'package:kfon_subscriber/painter/dashed_line_painter.dart';
import 'package:kfon_subscriber/service_locator.dart';

class TopupPage extends StatefulWidget {
  const TopupPage({super.key});

  @override
  State<TopupPage> createState() => _TopupPageState();
}

class _TopupPageState extends State<TopupPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedPaymentGateway;
  double _accountBalance = 30.00; // Default balance, can be fetched from API

  final List<int> _quickRechargeAmounts = [500, 750, 1000, 2000];
  final List<PaymentGateway> _paymentGateways = [
    PaymentGateway(
      id: 'hdfc',
      name: 'HDFC',
      icon: 'assets/images/hdfc_logo.png',
    ),
    PaymentGateway(id: 'ikm', name: 'IKM', icon: 'assets/images/ikm_logo.png'),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      _amountController.text = amount.toString();
    });
  }

  void _processPayment(BuildContext blocContext) {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPaymentGateway == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a payment gateway'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dispatch event to BLoC to initiate topup
    blocContext.read<TopupBloc>().add(
      InitiateTopup(
        amount: amount,
        paymentType: _selectedPaymentGateway!.toUpperCase(),
      ),
    );
  }

  void _showTopUpSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                SvgPicture.asset(
                  'assets/images/top-up_successfull.svg',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 26),
                // Title
                Text(
                  'Top-Up Successful!',
                  style: TextStyle(
                    color: const Color(0xFF0F1121),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                const SizedBox(height: 12),
                // Message
                Text(
                  'Thank you. your payment has been successfully received with the following details. Please quote you transaction reference number for any quueries relating to this request.',
                  style: TextStyle(
                    color: const Color(0xFF354259),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Transaction Details Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.kSecondaryBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        label:
                            'HDFC Transaction Reference\nNumber to the Banker',
                        value: '314013691309',
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        label: 'BSS Reference',
                        value: 'YVU86YZU930193852',
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        label: 'Transaction Date',
                        value: '15 Dec 2025  19:38:57',
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        label: 'Payment Amount (Rs)',
                        value: amount.toStringAsFixed(2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Note
                Text(
                  'Note : Paymnet will be creadited to your Rconverge Billing acoount within 3 Working Days',
                  style: TextStyle(
                    color: const Color(0xFF919191),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.82,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Ok Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ok',
                      style: TextStyle(
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
      },
    );
  }

  void _showTopUpFailedDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 27),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Failed Icon
                SvgPicture.asset(
                  'assets/images/top-up_fail.svg',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 26),
                // Title
                Text(
                  'Top-Up Failed',
                  style: TextStyle(
                    color: const Color(0xFF0F1121),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontFamily: 'GeneralSans',
                  ),
                ),
                const SizedBox(height: 13),
                // Message
                Text(
                  'Your recharge of ₹${amount.toStringAsFixed(2)} could not be completed.',
                  style: TextStyle(
                    color: const Color(0xFF354259),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                // Additional Message
                Text(
                  'Please check your payment method or network connection and try again.',
                  style: TextStyle(
                    color: const Color(0xFF354259),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.54,
                    fontFamily: 'GeneralSans',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                // Horizontal Dashed Divider
                Container(
                  width: 222,
                  height: 1,
                  child: CustomPaint(
                    painter: DashedLinePainter(
                      color: Colors.black.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Retry Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog but stay on page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: TextStyle(
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
      },
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF717171),
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
          style: TextStyle(
            color: const Color(0xFF262629),
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

  @override
  Widget build(BuildContext context) {
    final headerHeight = 191.0;
    final appBarTop = 68.0;
    final cardTop = 134.0;

    return BlocProvider(
      create: (context) => TopupBloc(repository: sl<TopupRepository>()),
      child: BlocListener<TopupBloc, TopupState>(
        listener: (context, state) async {
          if (state is TopupLoading) {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => const Center(child: CircularProgressIndicator()),
            );
          } else if (state is TopupSuccess) {
            // Dismiss loading dialog
            Navigator.of(context).pop();
            // Navigate to Payment WebView
            final result = await Navigator.push<PaymentResult>(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        PaymentWebViewPage(redirectEntity: state.redirectData),
              ),
            );
            // Handle payment result
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
            // Dismiss loading dialog if shown
            Navigator.of(context).pop();
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PaymentCompleted) {
            // Show success dialog
            _showTopUpSuccessDialog(state.amount ?? 0);
          } else if (state is PaymentFailed) {
            // Show failure dialog
            final amount = double.tryParse(_amountController.text) ?? 0;
            _showTopUpFailedDialog(amount);
          } else if (state is PaymentCancelled) {
            // Show cancellation message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment was cancelled'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.kMainBackgroundColor,
          body: Stack(
            children: [
              // Background Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: SvgPicture.asset(
                  'assets/images/speed_test_background.svg',
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
              ),
              // Custom App Bar
              Positioned(
                top: appBarTop,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Amount Top-Up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            fontFamily: 'GeneralSans',
                          ),
                        ),
                      ),
                      const SizedBox(width: 36), // Balance for back button
                    ],
                  ),
                ),
              ),
              // Enter Amount Card
              Positioned(
                top: cardTop,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    // width: 335,
                    height: 86,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13.54,
                      vertical: 19,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.kCardShadow,
                          blurRadius: 16,
                          offset: const Offset(0, 0),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '₹',
                                style: TextStyle(
                                  color: const Color(0xFF333333),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  height: 0.92,
                                  fontFamily: 'GeneralSans',
                                ),
                              ),
                              IntrinsicWidth(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'Enter Amount',
                                    hintStyle: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      height: 0.92,
                                      fontFamily: 'GeneralSans',
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  style: TextStyle(
                                    color: const Color(0xFF333333),
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
                        ),
                        const SizedBox(height: 5),
                        // Divider - Dotted Line
                        Container(
                          width: double.infinity,
                          height: 1,
                          child: CustomPaint(
                            painter: DashedLinePainter(
                              color: Colors.black.withValues(alpha: 0.20),
                              strokeWidth: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Account Balance : ',
                                style: TextStyle(
                                  color: const Color(0xFF646464),
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: '₹${_accountBalance.toStringAsFixed(2)}',
                                style: TextStyle(
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
                  ),
                ),
              ),
              // Scrollable Content Section (Quick Recharge + Payment Gateway)
              Positioned(
                top: cardTop + 86 + 20,
                // Card top + card height + spacing
                left: 0,
                right: 0,
                bottom: 34 + MediaQuery.of(context).padding.bottom + 52 + 20,
                // Button height + padding + spacing
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Recharge Section
                      Text(
                        'Quick Recharge',
                        style: TextStyle(
                          color: const Color(0xFF0F1121),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.start,
                        children:
                            _quickRechargeAmounts.map((amount) {
                              return GestureDetector(
                                onTap: () => _selectQuickAmount(amount),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(130),
                                  ),
                                  child: Text(
                                    '+$amount',
                                    style: TextStyle(
                                      color: AppColor.kPrimaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(
                        height: 24,
                      ), // Spacing between Quick Recharge and Payment Gateway
                      // Payment Gateway Section
                      Text(
                        'Select Payment Gateway',
                        style: TextStyle(
                          color: const Color(0xFF0F1121),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          fontFamily: 'GeneralSans',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._paymentGateways.map((gateway) {
                        final isSelected =
                            _selectedPaymentGateway == gateway.id;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPaymentGateway = gateway.id;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xFFEAEAEA),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // Payment Gateway Icon
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFFD9D9D9),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      gateway.icon,
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Payment Gateway Name
                                Expanded(
                                  child: Text(
                                    gateway.name,
                                    style: TextStyle(
                                      color: const Color(0xFF0F1121),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                      fontFamily: 'GeneralSans',
                                    ),
                                  ),
                                ),
                                // Radio Button
                                isSelected
                                    ? Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFF8D0247),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 2,
                                            color: const Color(0xFF8D0247),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: OvalBorder(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF67697A),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20), // Bottom padding for scroll
                    ],
                  ),
                ),
              ),
              // Process to Pay Button
              Positioned(
                bottom: 34 + MediaQuery.of(context).padding.bottom,
                left: 20,
                right: 20,
                child: Builder(
                  builder:
                      (blocContext) => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              _selectedPaymentGateway != null
                                  ? () => _processPayment(blocContext)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _selectedPaymentGateway != null
                                    ? AppColor.kPrimaryColor
                                    : Colors.grey,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            'Process to Pay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              fontFamily: 'GeneralSans',
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentGateway {
  final String id;
  final String name;
  final String icon;

  PaymentGateway({required this.id, required this.name, required this.icon});
}
