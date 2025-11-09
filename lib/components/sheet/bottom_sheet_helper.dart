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
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // we'll style inside
    barrierColor: Colors.black.withOpacity(0.3), // Soft overlay (30% opacity)
    isDismissible: isDismissible,
    builder: (context) {
      Widget sheet = BaseBottomSheet(title: title, child: child);

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
  );
}
