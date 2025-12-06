import 'package:flutter/material.dart';

class UserSelectionScreen extends StatefulWidget {
  final List<String> initialSelectedUsers;
  final Function(List<String>) onUsersSelected;

  const UserSelectionScreen({
    super.key,
    required this.initialSelectedUsers,
    required this.onUsersSelected,
  });

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  late List<String> _selectedUsers;

  // Placeholder user data - replace with actual user data later
  final List<String> _availableUsers = [
    'Alice Johnson',
    'Bob Smith',
    'Charlie Brown',
    'Diana Prince',
    'Eve Wilson',
  ];

  @override
  void initState() {
    super.initState();
    _selectedUsers = List.from(widget.initialSelectedUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Users'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onUsersSelected(_selectedUsers);
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _availableUsers.length,
        itemBuilder: (context, index) {
          final user = _availableUsers[index];
          final isSelected = _selectedUsers.contains(user);

          return CheckboxListTile(
            title: Text(user),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedUsers.add(user);
                } else {
                  _selectedUsers.remove(user);
                }
              });
            },
          );
        },
      ),
    );
  }
}
