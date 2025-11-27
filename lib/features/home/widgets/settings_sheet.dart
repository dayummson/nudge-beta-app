import 'package:flutter/material.dart';
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import 'package:nudge_1/features/debug/debug_db_screen.dart';
import 'package:nudge_1/features/home/widgets/theme_selector_sheet.dart';
import 'package:nudge_1/core/theme/theme_provider.dart';
import 'package:nudge_1/main.dart' as main_app;

/// Shows the settings bottom sheet with various app settings options.
///
/// Provides navigation to:
/// - Profile settings
/// - Notifications
/// - Theme customization
/// - Category editing
/// - Database debugging
/// - Help & Support
void showSettingsSheet(
  BuildContext context, {
  required VoidCallback onEditCategoriesPressed,
}) {
  showAppBottomSheet(
    context: context,
    title: 'Settings',
    mode: SheetMode.auto,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
            // TODO: Navigate to profile
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
            // TODO: Navigate to notifications
          },
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Theme'),
          onTap: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);

            // Get current theme
            final themeProvider = ThemeProvider();
            await themeProvider.loadThemePreference();

            // Show theme selector sheet
            if (context.mounted) {
              showThemeSelectorSheet(
                context,
                currentTheme: themeProvider.themeMode,
                onThemeSelected: (theme) async {
                  // Save theme preference and apply
                  await themeProvider.setThemeMode(theme);
                  main_app.themeNotifier.value =
                      themeProvider.themeMode2Flutter;
                },
              );
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Edit Categories'),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
            onEditCategoriesPressed();
          },
        ),
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('Debug: Database'),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const DebugDbScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
            // TODO: Navigate to help
          },
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
