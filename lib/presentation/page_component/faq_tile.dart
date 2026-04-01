import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';

class FaqTile extends StatefulWidget {
  final int questionNo;
  final String question;
  final String answer;

  const FaqTile({
    super.key,
    required this.questionNo,
    required this.question,
    required this.answer,
  });

  @override
  State<FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile> {
  bool isExpanded = false;
  final TextStyle questionStyle = TextStyle(
    color: AppColor.kTextSecondaryDark,
    fontSize: 14.sp,
    fontFamily: 'General Sans',
    fontWeight: FontWeight.w600,
    height: 1.30,
  );
  final TextStyle answerStyle = TextStyle(
    color: Colors.black.withValues(alpha: 0.70),
    fontSize: 12.sp,
    fontFamily: 'General Sans',
    fontWeight: FontWeight.w500,
    height: 1.60,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.kinputFiledLightBorder, width: 1.w),
      ),
      padding: EdgeInsets.only(left: 10,right: 14,top: 13,bottom: 13),
      child:Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.questionNo}. ', style: questionStyle),
          Expanded(
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.question, style: questionStyle),
                isExpanded
                    ?Text(widget.answer,style: answerStyle,)
                    :SizedBox.shrink()
              ],
            ),
          ),
          SizedBox(width: 12,),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              isExpanded ? Icons.remove : Icons.add,
              color: AppColor.kTextSecondaryDark,
              size: 20.w,
            ),
            onPressed: () {
              setState(() {
                isExpanded = isExpanded?false:true;
              });

            },
          )
        ],
      )

    );
  }
}
