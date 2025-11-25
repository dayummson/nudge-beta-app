import 'package:flutter/material.dart';
import './bottom_sheet.dart';

enum SheetMode { half, full, auto }

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  SheetMode mode = SheetMode.auto,
  double? heightFactor, // Custom height factor (0.0 to 1.0)
  bool isDismissible = true,
  EdgeInsetsGeometry? contentPadding,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // we'll style inside
    barrierColor: Colors.black.withOpacity(0.3), // Soft overlay (30% opacity)
    isDismissible: isDismissible,
    builder: (context) {
      // Get keyboard height to push content above it
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      Widget sheet = Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: BaseBottomSheet(
          title: title,
          child: child,
          contentPadding:
              contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );

      // Wrap with FractionallySizedBox for fixed height modes or custom height
      if (heightFactor != null) {
        // Use custom height factor if provided
        sheet = FractionallySizedBox(heightFactor: heightFactor, child: sheet);
      } else if (mode == SheetMode.half || mode == SheetMode.full) {
        final factor = mode == SheetMode.full ? 0.95 : 0.5;
        sheet = FractionallySizedBox(heightFactor: factor, child: sheet);
      }
      // SheetMode.auto will size to content naturally

      return sheet;
    },
  ).then((value) {
    // Unfocus when the sheet is dismissed to prevent keyboard from opening
    if (context.mounted) {
      FocusScope.of(context).unfocus();
    }
    return value;
  });
}
