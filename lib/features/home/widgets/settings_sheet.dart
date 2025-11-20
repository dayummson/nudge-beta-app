import 'package:flutter/material.dart';
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import 'package:nudge_1/features/debug/debug_db_screen.dart';

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
            Navigator.pop(context);
            // TODO: Navigate to profile
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to notifications
          },
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Theme'),
          onTap: () {
            Navigator.pop(context);
            // TODO: Navigate to theme settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.category),
          title: const Text('Edit Categories'),
          onTap: () {
            Navigator.pop(context);
            onEditCategoriesPressed();
          },
        ),
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('Debug: Database'),
          onTap: () {
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
            Navigator.pop(context);
            // TODO: Navigate to help
          },
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
