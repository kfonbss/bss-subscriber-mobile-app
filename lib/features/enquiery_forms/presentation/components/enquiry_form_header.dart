import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class EnquiryFormHeader extends StatelessWidget {
  final String heading;
  final int pageCount;
  final int currentPage;

  const EnquiryFormHeader({
    super.key,
    required this.heading,
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      margin: EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0),
      decoration: BoxDecoration(
        color: AppColor.kYellowBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 20,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 48.h,
                width: 48.w,
                child: CircularProgressIndicator(
                  value: currentPage / pageCount,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColor.kProgressBarBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColor.kPrimaryColor,
                  ),
                  strokeWidth: 6.0,
                ),
              ),
              Text(
                '$currentPage / $pageCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.kPrimaryColor,
                ),
              ),
            ],
          ),
          Expanded(
            child: Text(
              heading,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColor.kBlackHeadingColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
