import 'package:flutter/material.dart';

class FormScrollUtil {
  /// Scrolls to the first active error in a Form.
  ///
  /// This function finds all invalid FormFields in the given context and scrolls
  /// to the first one. It's useful when a form is long and the user submits
  /// with invalid fields that are off-screen.
  static void scrollToFirstError(BuildContext context) {
    // Find the first invalid FormField
    final invalidField = _findFirstInvalidField(context);

    if (invalidField != null) {
      // Ensure the widget is visible by scrolling to it
      Scrollable.ensureVisible(
        invalidField.context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.1, // Align slightly below the top of the viewport
      );
    }
  }

  static FormFieldState? _findFirstInvalidField(BuildContext context) {
    FormFieldState? firstInvalid;

    void visitor(Element element) {
      if (element.widget is FormField) {
        final FormFieldState state =
            (element as StatefulElement).state as FormFieldState;
        if (state.hasError) {
          firstInvalid ??= state;
        }
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return firstInvalid;
  }
}
