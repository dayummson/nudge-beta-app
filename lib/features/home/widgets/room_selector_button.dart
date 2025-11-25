import 'package:flutter/material.dart';
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import 'package:nudge_1/features/room/widgets/rooms_sheet.dart';

class RoomSelectorButton extends StatelessWidget {
  final VoidCallback? onRoomChanged;

  const RoomSelectorButton({super.key, this.onRoomChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ValueListenableBuilder<String?>(
      valueListenable: RoomSelection.selectedRoom,
      builder: (context, selId, _) {
        if (selId == null) {
          RoomSelection.getSelectedRoomId();
        }

        return StreamBuilder<List<Room>>(
          stream: AppDatabase().roomsDao.watchAllRooms(),
          builder: (context, snapshot) {
            var label = 'Rooms';
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final rooms = snapshot.data!;
              Room? chosen;
              if (selId != null) {
                try {
                  chosen = rooms.firstWhere((r) => r.id == selId);
                } catch (_) {
                  chosen = null;
                }
              }
              chosen ??= rooms.first;
              label = chosen.name;
            }

            return OutlinedButton(
              onPressed: () =>
                  showRoomsSheet(context, onRoomChanged: onRoomChanged),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                shape: const StadiumBorder(),
                side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.unfold_more,
                    size: 16,
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
