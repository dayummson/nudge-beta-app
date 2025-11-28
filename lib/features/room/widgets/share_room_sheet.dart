import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import 'package:nudge_1/core/db/app_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nudge_1/firebase/firestore/user_service.dart';
import 'package:nudge_1/firebase/firestore/room_service.dart';
import 'package:nudge_1/features/auth/domain/auth_service.dart';

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

    debugPrint('🔥 Starting room share process for room: ${_currentRoom.name}');

    // Check internet connectivity
    final connectivityResults = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResults.every(
      (result) => result == ConnectivityResult.none,
    );

    debugPrint('🌐 Internet connectivity check: $hasInternet');

    if (!hasInternet) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No internet connection. Please check your connection and try again.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _isConfirming = true);

    try {
      // Check if user has display name set
      final userService = UserService();
      final currentUser = FirebaseAuth.instance.currentUser;
      String? displayName;

      debugPrint('👤 Current Firebase user: ${currentUser?.uid ?? 'null'}');

      if (currentUser != null) {
        displayName = await userService.getDisplayName(currentUser.uid);
        debugPrint('📝 Display name from Firestore: $displayName');
      }

      // If no display name, show the display name sheet
      if (displayName == null || displayName.isEmpty) {
        debugPrint('📝 No display name found, showing display name sheet');
        if (mounted) {
          await showAppBottomSheet(
            context: context,
            mode: SheetMode.auto,
            child: _DisplayNameSheet(
              onSave: (name) async {
                debugPrint('💾 Saving display name: $name');
                // Authenticate anonymously if not already
                UserCredential userCredential;
                final authService = AuthService();
                if (currentUser == null) {
                  debugPrint('🔐 Signing in anonymously (new user)');
                  userCredential = await authService.signInAnonymously();
                } else {
                  debugPrint('🔐 Signing in anonymously (existing user)');
                  userCredential = await authService.signInAnonymously();
                  // Note: This will create a new anonymous user. In production,
                  // you might want to link the anonymous account to the existing user.
                }

                debugPrint(
                  '✅ Auth successful, user ID: ${userCredential.user!.uid}',
                );

                // Save display name to Firestore
                await userService.setDisplayName(
                  userCredential.user!.uid,
                  name,
                );
                debugPrint('💾 Display name saved to Firestore');

                // Create shared room in Firestore
                final roomService = RoomService();
                await roomService.createSharedRoom(
                  roomId: _currentRoom.id.toString(),
                  name: _currentRoom.name,
                  ownerId: userCredential.user!.uid,
                  users: [userCredential.user!.uid],
                );
                debugPrint(
                  '🏠 Shared room created in Firestore: ${_currentRoom.id}',
                );
              },
            ),
          );
        }
      } else {
        debugPrint('📝 Display name exists, proceeding with room creation');
        // User already has display name, authenticate if needed and create room
        UserCredential userCredential;
        final authService = AuthService();
        if (currentUser == null) {
          debugPrint('🔐 Signing in anonymously (new user)');
          userCredential = await authService.signInAnonymously();
        } else {
          debugPrint('🔐 Signing in anonymously (existing user)');
          userCredential = await authService.signInAnonymously();
          // Note: Similar note as above about linking accounts.
        }

        debugPrint('✅ Auth successful, user ID: ${userCredential.user!.uid}');

        // Create shared room in Firestore
        final roomService = RoomService();
        await roomService.createSharedRoom(
          roomId: _currentRoom.id.toString(),
          name: _currentRoom.name,
          ownerId: userCredential.user!.uid,
          users: [userCredential.user!.uid],
        );
        debugPrint('🏠 Shared room created in Firestore: ${_currentRoom.id}');
      }

      // Update local room to mark as shared
      final db = AppDatabase();
      final companion = _currentRoom
          .toCompanion(true)
          .copyWith(isShared: const drift.Value(true));
      await db.roomsDao.updateRoom(companion);
      debugPrint('💾 Local room marked as shared');

      // Update local room state to show QR code and link
      setState(() {
        _currentRoom = _currentRoom.copyWith(isShared: true);
      });
      debugPrint('✅ Room sharing process completed successfully');
    } catch (e) {
      debugPrint('❌ Error during room sharing: $e');
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

class _DisplayNameSheet extends StatefulWidget {
  final Future<void> Function(String) onSave;

  const _DisplayNameSheet({required this.onSave});

  @override
  State<_DisplayNameSheet> createState() => _DisplayNameSheetState();
}

class _DisplayNameSheetState extends State<_DisplayNameSheet> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _hasText = _controller.text.trim().isNotEmpty;
    _controller.addListener(() {
      final now = _controller.text.trim().isNotEmpty;
      if (now != _hasText) setState(() => _hasText = now);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final incomeColor = const Color(0xFF58CC02);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your Display Name',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This name will be visible to other users when you share rooms.',
                style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter your display name',
                  hintStyle: TextStyle(
                    color: cs.onSurface.withOpacity(0.45),
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _hasText
                      ? () async {
                          final trimmed = _controller.text.trim();
                          await widget.onSave(trimmed);
                          if (context.mounted) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Continue'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasText ? incomeColor : Colors.grey[850],
                    foregroundColor: _hasText ? Colors.white : cs.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 14,
                    ),
                    minimumSize: const Size(64, 48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
