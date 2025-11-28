import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import 'package:nudge_1/core/db/app_database.dart';

/// Shows the share room bottom sheet.
///
/// Allows users to share a room by generating a QR code and shareable link.
void showShareRoomSheet(BuildContext context, {required Room room}) {
  showAppBottomSheet(
    context: context,
    mode: SheetMode.auto,
    child: _ShareRoomSheetContent(room: room),
  );
}

class _ShareRoomSheetContent extends StatefulWidget {
  final Room room;

  const _ShareRoomSheetContent({required this.room});

  @override
  State<_ShareRoomSheetContent> createState() => _ShareRoomSheetContentState();
}

class _ShareRoomSheetContentState extends State<_ShareRoomSheetContent> {
  late Room _currentRoom;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    _currentRoom = widget.room;
  }

  Future<void> _confirmShare() async {
    if (_isConfirming) return;

    setState(() => _isConfirming = true);

    try {
      final db = AppDatabase();
      final companion = _currentRoom
          .toCompanion(true)
          .copyWith(isShared: const drift.Value(true));
      await db.roomsDao.updateRoom(companion);

      // Update local room state to show QR code and link
      setState(() {
        _currentRoom = _currentRoom.copyWith(isShared: true);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing room: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isConfirming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentRoom.isShared
                    ? 'Room Shared!'
                    : 'Share ${_currentRoom.name}?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              Text(
                _currentRoom.isShared
                    ? 'Share this link or scan the QR code to invite others.'
                    : 'Sharing this room will share all expenses and income.',
                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_currentRoom.isShared)
          // QR Code Placeholder
          Container(
            width: 200,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'QR Code Placeholder',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
              ),
            ),
          ),
        if (_currentRoom.isShared) const SizedBox(height: 24),
        if (_currentRoom.isShared)
          // Shareable Link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://nudge.app/room/${_currentRoom.id}',
                      style: TextStyle(color: cs.onSurface, fontSize: 14),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement copy functionality
                    },
                    icon: Icon(
                      Icons.copy,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_currentRoom.isShared) const SizedBox(height: 32),
        // Confirm Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            onPressed: _isConfirming
                ? null
                : (_currentRoom.isShared
                      ? () => Navigator.of(context).pop()
                      : _confirmShare),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: const Color(0xFF58CC02),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: _isConfirming
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onPrimary,
                    ),
                  )
                : Text(_currentRoom.isShared ? 'Done' : 'Confirm Share'),
          ),
        ),
        const SizedBox(height: 20), // Space to avoid keyboard covering bottom
      ],
    );
  }
}
