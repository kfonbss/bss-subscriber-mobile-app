import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';

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

  void showMessage(String error, BuildContext context, {Color? backgroundColor}) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor ?? Colors.red,
      ),
    );
  }

}
