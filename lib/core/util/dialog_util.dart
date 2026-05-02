import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/shared/widgets/common_bottom_sheet.dart';

class DialogUtil {
  static final _contentStyle = const TextStyle(
    color: Colors.black,
    fontSize: 15.0,
  );
  static final _positiveButtonStyle = const TextStyle(
    color: AppColor.kCompletedGreen,
  );
  static final _negativeButtonStyle = const TextStyle(color: AppColor.kFailedRed);
  static final _logo = Image.asset('assets/images/logo.png', height: 50.0);

  showConfirmationAlert({
    required BuildContext context,
    required String content,
    required VoidCallback onPositiveButtonClick,
    required VoidCallback onNegativeButtonClick,
  }) {
    final negativeButton = TextButton(
      onPressed: onNegativeButtonClick,
      child: Text("No", style: _negativeButtonStyle),
    );
    final positiveButton = TextButton(
      onPressed: onPositiveButtonClick,
      child: Text("Yes", style: _positiveButtonStyle),
    );

    // set up the AlertDialog
    final alert = AlertDialog(
      //title: Text(kAppName,style: _titleStyle),
      icon: _logo,
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
    final positiveButton = TextButton(
      onPressed: onConfirmation,
      child: Text("Ok", style: _positiveButtonStyle),
    );

    // set up the AlertDialog
    final alert = AlertDialog(
      icon: _logo,
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

  /// Shows a progress dialog while [task] runs, then dismisses it
  /// automatically — whether [task] completes normally or throws.
  ///
  /// Returns the result of [task], or rethrows its error after closing
  /// the dialog.
  ///
  /// Example:
  /// ```dart
  /// final result = await DialogUtil().runWithProgress(
  ///   context: context,
  ///   label: 'Uploading…',
  ///   task: () => myRepository.upload(data),
  /// );
  /// ```
  Future<T> runWithProgress<T>({
    required BuildContext context,
    required String label,
    required Future<T> Function() task,
  }) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            content: Row(
              spacing: 15,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColor.kPrimaryColor),
                Text(label, style: _contentStyle),
              ],
            ),
            elevation: 5.0,
            backgroundColor: Colors.white,
          ),
        );
      },
    );

    try {
      final result = await task();
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      return result;
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      rethrow;
    }
  }
  /// Convenience wrapper — delegates to [showCustomSnackbar].
  void showMessage(
    String content,
    BuildContext context, {
    Color? backgroundColor,
  }) {
    showCustomSnackbar(
      context: context,
      content: content,
      backgroundColor: backgroundColor ?? AppColor.kFailedRed,
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
    final negativeButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColor.kPrimaryColor),
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onNegativeButtonClick ?? () => Navigator.pop(context),
      child: Text('No'),
    );
    final positiveButton = ElevatedButton(
      onPressed: onPositiveButtonClick,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.5),
      ),
      child: Text('Yes'),
    );

    final contentWidget = Padding(
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
}
