import 'package:flutter/material.dart';
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';

enum AppThemeMode { light, dark, system }

/// Shows the theme selector bottom sheet with theme options.
///
/// Provides options to select:
/// - Light theme
/// - Dark theme
/// - System theme (follows device settings)
void showThemeSelectorSheet(
  BuildContext context, {
  AppThemeMode? currentTheme,
  required Function(AppThemeMode) onThemeSelected,
}) {
  showAppBottomSheet(
    context: context,
    title: 'Select Theme',
    mode: SheetMode.auto,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.light_mode),
          title: const Text('Light'),
          trailing: currentTheme == AppThemeMode.light
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () {
            onThemeSelected(AppThemeMode.light);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Dark'),
          trailing: currentTheme == AppThemeMode.dark
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () {
            onThemeSelected(AppThemeMode.dark);
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.brightness_auto),
          title: const Text('System'),
          subtitle: const Text('Follow device settings'),
          trailing: currentTheme == AppThemeMode.system
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () {
            onThemeSelected(AppThemeMode.system);
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
