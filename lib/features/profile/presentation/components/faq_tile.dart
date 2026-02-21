import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const FaqTile({super.key, required this.question, required this.answer});

  @override
  State<FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
          ),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          trailing: Icon(
            isExpanded ? Icons.remove : Icons.add,
            color: const Color(0xFF0F1121),
            size: 20.w,
          ),
          onExpansionChanged: (value) {
            setState(() {
              isExpanded = value;
            });
          },
          tilePadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
          childrenPadding: EdgeInsets.only(
            left: 21.w,
            right: 6.w,
            bottom: 12.h,
          ),
          title: Padding(
            padding: EdgeInsets.only(left: 15.w),
            child: Text(
              widget.question,
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F1121),
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
          ),
          children: [
            Padding(
              padding: EdgeInsets.only(left: 21.w),
              child: Text(
                widget.answer,
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black.withOpacity(0.7),
                  height: 1.6,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
