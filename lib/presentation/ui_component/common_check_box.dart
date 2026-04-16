import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

class CommonCheckBox extends StatefulWidget {
  final bool initialStatus;
  final String title;
  final Function(bool) onChanged;

  const CommonCheckBox({
    super.key,
    required this.title,
    required this.onChanged,
    required this.initialStatus,
  });

  @override
  State<CommonCheckBox> createState() => _CommonCheckBoxState();
}

class _CommonCheckBoxState extends State<CommonCheckBox>
    with AutomaticKeepAliveClientMixin {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          activeColor: AppColor.kPrimaryColor,
          checkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              5.0,
            ), // Adjust the radius as needed
          ),
          side: const BorderSide(color: AppColor.kMediumGrey, width: 1.0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          value: _isChecked,
          onChanged: (bool? newValue) {
            setState(() {
              _isChecked = newValue!;
              widget.onChanged(newValue);
            });
          },
        ),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              color: AppColor.kBlackHeadingColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
