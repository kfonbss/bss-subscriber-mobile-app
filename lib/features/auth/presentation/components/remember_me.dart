import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_check_box.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';

class RememberMe extends StatefulWidget {
  final ValueChanged<bool>? onChanged;

  const RememberMe({super.key, required this.onChanged});

  @override
  State<RememberMe> createState() => _RememberMeState();
}

class _RememberMeState extends State<RememberMe> {
  late bool _rememberMe = false;
  final double size = 20;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final username = await PreferenceUtils.getUsername();
    if (!mounted) return;
    setState(() {
      _rememberMe = username == null ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // White fill with a primary tick, over the login backdrop.
    return CommonCheckBox(
      title: context.bssSubL10n.rememberMe,
      value: _rememberMe,
      activeColor: Colors.white,
      checkColor: AppColor.kPrimaryColor,
      spacing: 6.w,
      onChanged: (val) {
        setState(() => _rememberMe = val);
        widget.onChanged?.call(val);
      },
      textStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        fontFamily: 'General Sans',
        height: 1.30.h,
      ),
    );
  }
}
