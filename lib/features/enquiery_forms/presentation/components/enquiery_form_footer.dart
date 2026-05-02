import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/constant_dimensions.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';

class EnquiryFormFooter extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final VoidCallback primaryButtonCallback;
  final VoidCallback secondaryButtonCallback;
  final bool showLoading;

  const EnquiryFormFooter({
    super.key,
    required this.pageCount,
    required this.currentPage,
    required this.primaryButtonCallback,
    required this.secondaryButtonCallback,
    required this.showLoading,
  });

  _getStep(bool isActive) {
    return Expanded(
      child: Container(
        height: 5,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColor.kPrimaryColor : AppColor.kBorderLightGrey,
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Row(
              children: List.generate(
                pageCount,
                    (index) => _getStep(currentPage == (index + 1)),
              ),
            ),
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: SecondaryButton(
                  label: currentPage == 1 ? l10n.cancel : l10n.back,
                  icon: Icon(
                    currentPage == 1
                        ? Icons.cancel_outlined
                        : Icons.arrow_circle_left_outlined,
                    color: AppColor.kPrimaryColor,
                    size: AppDimensions.kButtonIconSize,
                  ),
                  onClicked: currentPage == 1
                      ? () => Navigator.of(context).pop()
                      : secondaryButtonCallback,
                ),
              ),
              Expanded(
                child: PrimaryButton(
                  label: currentPage == pageCount
                      ? l10n.submit
                      : l10n.saveAndContinue,
                  onClicked: primaryButtonCallback,
                  isLoading: showLoading,
                  icon: Icon(
                    currentPage == pageCount
                        ? Icons.check_circle_outline
                        : Icons.arrow_circle_right_outlined,
                    color: Colors.white,
                    size: AppDimensions.kButtonIconSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
