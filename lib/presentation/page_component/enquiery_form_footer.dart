import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/constant/constant_dimensions.dart';
import 'package:kfon_subscriber/presentation/ui_component/primary_button.dart';
import 'package:kfon_subscriber/presentation/ui_component/secondary_button.dart';

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
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: isActive ? AppColor.kPrimaryColor : Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, -5), // Negative dy value to show shadow on top
          ),
        ],
      ),
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 100),
            child: Row(
              children: List.generate(
                pageCount,
                (index) => _getStep(
                  currentPage == (index + 1) ? true : false,
                ), // Or any other widget
              ),
            ),
          ),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: SecondaryButton(
                  label: currentPage == 1 ? 'Cancel' : 'Back',
                  icon: Icon(
                    currentPage == 1
                        ? Icons.cancel_outlined
                        : Icons.arrow_circle_left_outlined,
                    color: AppColor.kPrimaryColor,
                    size: AppDimensions.kButtonIconSize,
                  ),
                  onClicked:
                      currentPage == 1
                          ? () => Navigator.of(context).pop()
                          : secondaryButtonCallback,
                ),
              ),
              Expanded(
                child: PrimaryButton(
                  label:
                      currentPage == pageCount ? 'Submit' : 'Save & Continue',
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
