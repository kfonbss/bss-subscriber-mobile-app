import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_bottom_sheet.dart';

class DialogUtil {
  final TextStyle _contentStyle = TextStyle(
    color: Colors.black,
    fontSize: 15.0,
  );
  final TextStyle _positiveButtonStyle = TextStyle(
    color: Colors.green.shade600,
  );
  final TextStyle _negativeButtonStyle = TextStyle(color: Colors.red);
  final Widget logo = Image.asset('assets/images/logo.png', height: 50.0);

  showConfirmationAlert({
    required BuildContext context,
    required String content,
    required VoidCallback onPositiveButtonClick,
    required VoidCallback onNegativeButtonClick,
  }) {
    Widget negativeButton = TextButton(
      onPressed: onNegativeButtonClick,
      child: Text("No", style: _negativeButtonStyle),
    );
    Widget positiveButton = TextButton(
      onPressed: onPositiveButtonClick,
      child: Text("Yes", style: _positiveButtonStyle),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      //title: Text(kAppName,style: _titleStyle),
      icon: logo,
      content: Text(content, style: _contentStyle),
      actions: [negativeButton, positiveButton],
      elevation: 5.0,
      backgroundColor: Colors.white,
    );

    // show the dialog
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(canPop: false, child: alert);
      },
    );
  }

  showOKWithAction({
    required BuildContext context,
    required String content,
    required VoidCallback onConfirmation,
  }) {
    Widget positiveButton = TextButton(
      onPressed: onConfirmation,
      child: Text("Ok", style: _positiveButtonStyle),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      icon: logo,
      content: Text(content, style: _contentStyle),
      actions: [positiveButton],
      elevation: 5.0,
      backgroundColor: Colors.white,
    );

    // show the dialog
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(canPop: false, child: alert);
      },
    );
  }

  showProgressIndicator(BuildContext context, String label) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(contentPadding: EdgeInsets.all(20),
            content: Row(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColor.kPrimaryColor),
                Text(label, style: _contentStyle),
              ],
            ),
            elevation: 5.0,
            backgroundColor: Colors.white,
          ),
        );
      },
    );
  }
  void showCustomSnackbar({
    required BuildContext context,
    required String content,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,

          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColor.kPrimaryColor, // your maroon
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  showConfirmationSheet({
    required BuildContext context,
    required String content,
    String? title,
    required VoidCallback onPositiveButtonClick,
    VoidCallback? onNegativeButtonClick,
  }) {
    Widget negativeButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColor.kPrimaryColor),
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onNegativeButtonClick ?? () => Navigator.pop(context),
      child: Text('No'),
    );
    Widget positiveButton = ElevatedButton(
      onPressed: onPositiveButtonClick,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.5),
      ),
      child: Text('Yes'),
    );

    Widget contentWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
          ],
          SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: negativeButton),
                SizedBox(width: 24),
                Expanded(child: positiveButton),
              ],
            ),
          ),
        ],
      ),
    );

    // show the dialog
    return showAppModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return PopScope(canPop: false, child: contentWidget);
      },
    );
  }
  void showMessage(String error, BuildContext context, {Color? backgroundColor}) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor ?? Colors.red,
      ),
    );
  }

}
