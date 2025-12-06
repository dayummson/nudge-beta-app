import 'package:flutter/material.dart';
import 'user_selection_screen.dart';

class UserSelectorButton extends StatelessWidget {
  final List<String> selectedUsers;
  final Function(List<String>) onUsersSelected;

  const UserSelectorButton({
    super.key,
    required this.selectedUsers,
    required this.onUsersSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: () => _showUserSelectionSheet(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: const StadiumBorder(),
        side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selectedUsers.isEmpty
                ? 'Users'
                : '${selectedUsers.length} user${selectedUsers.length == 1 ? '' : 's'}',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.people, size: 16, color: cs.onSurface.withOpacity(0.5)),
        ],
      ),
    );
  }

  void _showUserSelectionSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserSelectionScreen(
          initialSelectedUsers: selectedUsers,
          onUsersSelected: onUsersSelected,
        ),
      ),
    );
  }
}
