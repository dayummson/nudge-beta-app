import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';

void showRoomsSheet(BuildContext context, {VoidCallback? onRoomChanged}) {
  final cs = Theme.of(context).colorScheme;
  final db = AppDatabase();

  Future<void> ensureDefault() async {
    final existing = await db.roomsDao.getAllRooms();
    if (existing.isEmpty) {
      await db.roomsDao.insertRoom(
        RoomsCompanion(
          id: const drift.Value('room-private'),
          name: const drift.Value('Private list'),
          ownerId: const drift.Value('local-user'),
          isShared: const drift.Value(false),
          users: const drift.Value(['local-user']),
        ),
      );
    }
  }

  showAppBottomSheet(
    context: context,
    title: null,
    mode: SheetMode.auto,
    child: StatefulBuilder(
      builder: (context2, setState2) {
        String? selectedId;

        return FutureBuilder<void>(
          future: ensureDefault(),
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Close button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: cs.onSurface),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                // Title and Add Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your rooms',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'choose your current room',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: cs.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () async {
                            await showAppBottomSheet(
                              context: context,
                              title: null,
                              mode: SheetMode.auto,
                              child: _EditRoomSheet(
                                initialName: '',
                                onSave: (newName) async {
                                  final id =
                                      'room-${DateTime.now().millisecondsSinceEpoch}';
                                  await db.roomsDao.insertRoom(
                                    RoomsCompanion(
                                      id: drift.Value(id),
                                      name: drift.Value(newName),
                                      ownerId: const drift.Value('local-user'),
                                      isShared: const drift.Value(false),
                                      users: const drift.Value(['local-user']),
                                    ),
                                  );
                                  await RoomSelection.setSelectedRoomId(id);
                                  if (context2.mounted) {
                                    setState2(() => selectedId = id);
                                  }
                                  onRoomChanged?.call();
                                },
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 10,
                            ),
                            shape: const StadiumBorder(),
                            minimumSize: const Size(40, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide(
                              color: cs.onSurface.withOpacity(0.12),
                            ),
                          ),
                          child: const Text(
                            '+',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Rooms List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: StreamBuilder<List<Room>>(
                    stream: db.roomsDao.watchAllRooms(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final rooms = snapshot.data!;
                      if (rooms.isEmpty) return const SizedBox.shrink();

                      if (selectedId == null) {
                        Future.microtask(() async {
                          final persisted =
                              await RoomSelection.getSelectedRoomId();
                          final toSet = persisted ?? rooms.first.id;
                          await RoomSelection.setSelectedRoomId(toSet);
                          if (context2.mounted) {
                            setState2(() => selectedId = toSet);
                          }
                          onRoomChanged?.call();
                        });
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: rooms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final r = rooms[index];
                          final isSelected = selectedId == r.id;

                          return Slidable(
                            key: ValueKey(r.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: r.id == 'room-private' ? 0.2 : 0.3,
                              children: [
                                CustomSlidableAction(
                                  onPressed: (ctx) async {
                                    // Edit
                                    await showAppBottomSheet(
                                      context: context,
                                      title: null,
                                      mode: SheetMode.auto,
                                      child: _EditRoomSheet(
                                        initialName: r.name,
                                        onSave: (newName) async {
                                          await db.roomsDao.updateRoom(
                                            RoomsCompanion(
                                              id: drift.Value(r.id),
                                              name: drift.Value(newName),
                                              ownerId: drift.Value(r.ownerId),
                                              isShared: drift.Value(r.isShared),
                                              users: drift.Value(r.users),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: cs.onSurface,
                                  child: const Icon(Icons.edit),
                                ),
                                if (r.id != 'room-private')
                                  CustomSlidableAction(
                                    onPressed: (ctx) async {
                                      // Delete
                                      final confirm = await showDialog<bool>(
                                        context: context2,
                                        builder: (dc) => AlertDialog(
                                          title: const Text('Delete room'),
                                          content: const Text(
                                            'Are you sure you want to delete this room?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dc, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dc, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await db.roomsDao.deleteRoomById(r.id);
                                        if (isSelected) {
                                          final remaining = await db.roomsDao
                                              .getAllRooms();
                                          if (remaining.isNotEmpty) {
                                            await RoomSelection.setSelectedRoomId(
                                              remaining.first.id,
                                            );
                                            if (context2.mounted) {
                                              setState2(
                                                () => selectedId =
                                                    remaining.first.id,
                                              );
                                            }
                                            onRoomChanged?.call();
                                          } else {
                                            await RoomSelection.clear();
                                            if (context2.mounted) {
                                              setState2(
                                                () => selectedId = null,
                                              );
                                            }
                                          }
                                        }
                                      }
                                    },
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: cs.onSurface,
                                    child: const Icon(Icons.delete),
                                  ),
                                CustomSlidableAction(
                                  onPressed: (ctx) {
                                    // Share placeholder
                                  },
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: cs.onSurface,
                                  child: const Icon(Icons.share),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () async {
                                await RoomSelection.setSelectedRoomId(r.id);
                                onRoomChanged?.call();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 0,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainerHighest,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '🤫',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 12,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Only you',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: cs.onSurface
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check, color: cs.primary),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    ),
  );
}

class _EditRoomSheet extends StatefulWidget {
  final String initialName;
  final Future<void> Function(String) onSave;

  const _EditRoomSheet({required this.initialName, required this.onSave});

  @override
  State<_EditRoomSheet> createState() => _EditRoomSheetState();
}

class _EditRoomSheetState extends State<_EditRoomSheet> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
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
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Room name',
                  hintStyle: TextStyle(
                    color: cs.onSurface.withOpacity(0.45),
                    fontSize: 28,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
                textAlign: TextAlign.left,
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
                            Navigator.pop(context);
                          }
                        }
                      : null,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Save'),
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
