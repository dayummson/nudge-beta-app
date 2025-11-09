import 'package:flutter/material.dart';
import './bottom_sheet.dart';

enum SheetMode { half, full, auto }

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  SheetMode mode = SheetMode.auto,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // we'll style inside
    isDismissible: isDismissible,
    builder: (context) {
      Widget sheet = BaseBottomSheet(title: title, child: child);

      // Wrap with FractionallySizedBox only for fixed height modes
      if (mode == SheetMode.half || mode == SheetMode.full) {
        final heightFactor = mode == SheetMode.full ? 0.95 : 0.5;
        sheet = FractionallySizedBox(heightFactor: heightFactor, child: sheet);
      }
      // SheetMode.auto will size to content naturally

      return sheet;
    },
  );
}
