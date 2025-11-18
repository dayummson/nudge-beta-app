import "package:flutter/material.dart";
import 'dart:ui';
import 'toggle_mode.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import '../../../components/sheet/bottom_sheet_helper.dart';
import '../../../constants/categories.dart';
import '../../../features/debug/debug_db_screen.dart';

class Header extends StatelessWidget {
  final double blurSigma;
  final double overlayOpacity;
  final double totalAmount;
  final bool isExpense;
  final void Function(bool) toggleMode;
  // Optional debug overrides (null in normal mode)
  final double? debugBlurOverride;
  final Color? debugOverlayColor;

  const Header({
    super.key,
    required this.blurSigma,
    required this.overlayOpacity,
    required this.totalAmount,
    required this.isExpense,
    required this.toggleMode,
    this.debugBlurOverride,
    this.debugOverlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,

      child: Stack(
        children: [
          // Background layer with blur and fade
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  Colors.black, // Solid at top
                  Colors.black, // Keep solid throughout header content
                  Colors.transparent, // Smooth fade at bottom
                ],
                stops: const [
                  0.0,
                  0.85, // Keep solid until 85% (after toggle mode)
                  1.0, // Smooth fade to transparent
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: debugBlurOverride ?? blurSigma,
                  sigmaY: debugBlurOverride ?? blurSigma,
                ),
                child: Container(
                  color:
                      debugOverlayColor ??
                      colorScheme.surface.withOpacity(overlayOpacity),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          // Top row: title + settings
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(child: SizedBox()),
                              const SizedBox(
                                width: 20,
                                height: 20,
                              ), // Placeholder for alignment
                            ],
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 19), // Placeholder for total
                          const SizedBox(height: 8),
                          const SizedBox(height: 79), // Placeholder for toggle
                          const SizedBox(height: 12), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content layer (not affected by ShaderMask)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Top row: title + settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () => _showSettingsSheet(context),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.settings,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Total in header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              border: Border.all(
                                color: colorScheme.onSurface.withOpacity(0.2),
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '-',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            totalAmount.toStringAsFixed(2),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Toggle with fade section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = constraints.maxWidth;
                        final toggleW = maxW.isFinite
                            ? (maxW * 0.9).clamp(140.0, 200.0)
                            : 180.0;
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: ToggleMode(
                            isExpense: isExpense,
                            onChanged: (val) => toggleMode(val),
                            width: toggleW,
                            height: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8), // reduced bottom padding
                  // Row with Month selector and Rooms button under the toggle
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: () => _showMonthSheet(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            shape: const StadiumBorder(),
                            minimumSize: const Size(64, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: colorScheme.onSurface.withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'All time',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.unfold_more,
                                size: 18,
                                color: colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            'in',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _showRoomsSheet(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            shape: const StadiumBorder(),
                            minimumSize: const Size(64, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: colorScheme.onSurface.withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FutureBuilder<String?>(
                                future: RoomSelection.getSelectedRoomId(),
                                builder: (context, selSnap) {
                                  final selId = selSnap.data;
                                  return StreamBuilder<List<Room>>(
                                    stream: AppDatabase().roomsDao
                                        .watchAllRooms(),
                                    builder: (context, snapshot) {
                                      var label = 'Rooms';
                                      if (snapshot.hasData &&
                                          snapshot.data!.isNotEmpty) {
                                        final rooms = snapshot.data!;
                                        Room? chosen;
                                        if (selId != null) {
                                          try {
                                            chosen = rooms.firstWhere(
                                              (r) => r.id == selId,
                                            );
                                          } catch (_) {
                                            chosen = null;
                                          }
                                        }
                                        chosen ??= rooms.first;
                                        label = chosen.name;
                                      }
                                      return Text(
                                        label,
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.unfold_more,
                                size: 18,
                                color: colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
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
              _showEditCategoriesSheet(context);
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

  void _showEditCategoriesSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Categories',
      mode: SheetMode.auto,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Categories Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  // Add button at the end
                  if (index == categories.length) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          child: DashedBorder(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                            strokeWidth: 2,
                            dashLength: 8,
                            gapLength: 4,
                            child: Center(
                              child: Icon(
                                Icons.add,
                                size: 24,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    );
                  }

                  // Category item
                  final category = categories[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final year = DateTime.now().year.toString();
    final months = const [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    showAppBottomSheet(
      context: context,
      title: null,
      mode: SheetMode.auto,
      child: StatefulBuilder(
        builder: (context2, setState2) {
          int selectedMode = 0;
          final Color bg = Colors.grey[850] ?? Colors.grey.shade900;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Month',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () => setState2(() => selectedMode = 0),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          shape: const StadiumBorder(),
                          backgroundColor: selectedMode == 0
                              ? bg
                              : Colors.transparent,
                          side: BorderSide(
                            color: selectedMode == 0
                                ? Colors.black.withOpacity(0.6)
                                : bg,
                          ),
                        ),
                        child: const Text('All time'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => setState2(() => selectedMode = 1),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          shape: const StadiumBorder(),
                          backgroundColor: selectedMode == 1
                              ? bg
                              : Colors.transparent,
                          side: BorderSide(
                            color: selectedMode == 1
                                ? Colors.black.withOpacity(0.6)
                                : bg,
                          ),
                        ),
                        child: Text(year),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: months.length,
                      itemBuilder: (context, index) => TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Center(child: Text(months[index])),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Apply'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(64, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRoomsSheet(BuildContext context) async {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
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
                              // open create-room sheet without a controller (use local state)
                              String name = '';
                              final incomeColor = const Color(0xFF58CC02);

                              await showAppBottomSheet(
                                context: context,
                                title: null,
                                mode: SheetMode.auto,
                                child: StatefulBuilder(
                                  builder: (context3, setState3) {
                                    return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.8,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextField(
                                                onChanged: (v) =>
                                                    setState3(() => name = v),
                                                decoration: InputDecoration(
                                                  hintText: 'Room name',
                                                  hintStyle: TextStyle(
                                                    color: cs.onSurface
                                                        .withOpacity(0.45),
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
                                                  onPressed:
                                                      name.trim().isNotEmpty
                                                      ? () async {
                                                          final id =
                                                              'room-${DateTime.now().millisecondsSinceEpoch}';
                                                          final trimmed = name
                                                              .trim();
                                                          await db.roomsDao.insertRoom(
                                                            RoomsCompanion(
                                                              id: drift.Value(
                                                                id,
                                                              ),
                                                              name: drift.Value(
                                                                trimmed,
                                                              ),
                                                              ownerId:
                                                                  const drift.Value(
                                                                    'local-user',
                                                                  ),
                                                              isShared:
                                                                  const drift.Value(
                                                                    false,
                                                                  ),
                                                              users:
                                                                  const drift.Value([
                                                                    'local-user',
                                                                  ]),
                                                            ),
                                                          );
                                                          await RoomSelection.setSelectedRoomId(
                                                            id,
                                                          );
                                                          Navigator.pop(
                                                            context3,
                                                          );
                                                          setState2(
                                                            () =>
                                                                selectedId = id,
                                                          );
                                                        }
                                                      : null,
                                                  icon: const Icon(
                                                    Icons.check,
                                                    size: 18,
                                                  ),
                                                  label: const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 12.0,
                                                        ),
                                                    child: Text('Save'),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        name.trim().isNotEmpty
                                                        ? incomeColor
                                                        : Colors.grey[850],
                                                    foregroundColor:
                                                        name.trim().isNotEmpty
                                                        ? Colors.white
                                                        : cs.onSurface,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 0,
                                                          horizontal: 14,
                                                        ),
                                                    minimumSize: const Size(
                                                      64,
                                                      48,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: StreamBuilder<List<Room>>(
                      stream: db.roomsDao.watchAllRooms(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        final rooms = snapshot.data!;
                        if (rooms.isEmpty) return const SizedBox.shrink();

                        if (selectedId == null) {
                          Future.microtask(() async {
                            final persisted =
                                await RoomSelection.getSelectedRoomId();
                            final toSet = persisted ?? rooms.first.id;
                            await RoomSelection.setSelectedRoomId(toSet);
                            setState2(() => selectedId = toSet);
                          });
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: rooms.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final r = rooms[index];
                            final isSelected = selectedId == r.id;
                            return InkWell(
                              onTap: () async {
                                await RoomSelection.setSelectedRoomId(r.id);
                                setState2(() => selectedId = r.id);
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
                                        color: Colors.grey[850],
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
                                    const SizedBox(width: 8),
                                    if (isSelected)
                                      Icon(Icons.check, color: cs.primary)
                                    else
                                      const SizedBox.shrink(),
                                  ],
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
}

// Helper widget for dashed border
class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const DashedBorder({
    super.key,
    required this.child,
    required this.color,
    this.strokeWidth = 1,
    this.dashLength = 5,
    this.gapLength = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      bool draw = true;

      while (distance < metric.length) {
        final length = draw ? dashLength : gapLength;
        final end = distance + length;

        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, end.clamp(0, metric.length)),
            Offset.zero,
          );
        }

        distance = end;
        draw = !draw;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
