import "package:flutter/material.dart";
import 'dart:ui';
import 'toggle_mode.dart';
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import '../../room/widgets/rooms_sheet.dart';
import 'settings_sheet.dart';
import 'month_sheet.dart';
import '../../categories/widgets/categories_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/selected_category_provider.dart';

class Header extends ConsumerStatefulWidget {
  final double blurSigma;
  final double overlayOpacity;
  final double totalAmount;
  final double expenseTotal;
  final double incomeTotal;
  final bool isExpense;
  final void Function(bool) toggleMode;
  final VoidCallback? onRoomChanged;
  final Function(int?, int?)? onMonthFilterChanged;
  final Map<int, double>? monthTotals;
  // Optional debug overrides (null in normal mode)
  final double? debugBlurOverride;
  final Color? debugOverlayColor;

  const Header({
    super.key,
    required this.blurSigma,
    required this.overlayOpacity,
    required this.totalAmount,
    required this.expenseTotal,
    required this.incomeTotal,
    required this.isExpense,
    required this.toggleMode,
    this.onRoomChanged,
    this.onMonthFilterChanged,
    this.monthTotals,
    this.debugBlurOverride,
    this.debugOverlayColor,
  });

  @override
  ConsumerState<Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<Header> {
  String _monthDisplayText = 'All time';
  int? _selectedMonth; // null for "All time", 1-12 for specific month
  int? _selectedYear; // null for "All time", year value for specific year

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCategory = ref.watch(selectedCategoryProvider);

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
                  sigmaX: widget.debugBlurOverride ?? widget.blurSigma,
                  sigmaY: widget.debugBlurOverride ?? widget.blurSigma,
                ),
                child: Container(
                  color:
                      widget.debugOverlayColor ??
                      colorScheme.surface.withOpacity(widget.overlayOpacity),
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
                            widget.totalAmount.toStringAsFixed(2),
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
                            isExpense: widget.isExpense,
                            onChanged: (val) => widget.toggleMode(val),
                            expenseTotal: widget.expenseTotal,
                            incomeTotal: widget.incomeTotal,
                            width: toggleW,
                            height: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8), // reduced bottom padding
                  // Row with Month/Category selector and Rooms button under the toggle
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Show either month selector or selected category
                        if (selectedCategory == null)
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
                                  _monthDisplayText,
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
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: selectedCategory.color.withOpacity(0.1),
                              border: Border.all(
                                color: selectedCategory.color.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedCategory.icon,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  selectedCategory.name,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: _clearCategoryFilter,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: colorScheme.onSurface.withOpacity(
                                        0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                  ),
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
                              ValueListenableBuilder<String?>(
                                valueListenable: RoomSelection.selectedRoom,
                                builder: (context, selId, _) {
                                  // If notifier hasn't been initialized yet,
                                  // trigger a load of the persisted value. This
                                  // will update the notifier once the Future
                                  // completes and cause a rebuild.
                                  if (selId == null) {
                                    RoomSelection.getSelectedRoomId();
                                  }

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
    showSettingsSheet(
      context,
      onEditCategoriesPressed: () => showCategoriesSheet(context),
    );
  }

  void _showMonthSheet(BuildContext context) {
    showMonthSheet(
      context,
      currentDisplayText: _monthDisplayText,
      isExpense: widget.isExpense,
      monthTotals: widget.monthTotals,
      onApply: (String newText, int? month, int? year) {
        setState(() {
          _monthDisplayText = newText;
          _selectedMonth = month;
          _selectedYear = year;
        });
        // Notify parent about filter change
        widget.onMonthFilterChanged?.call(month, year);
      },
    );
  }

  void _clearCategoryFilter() {
    ref.read(selectedCategoryProvider.notifier).clearCategory();
  }

  void _showRoomsSheet(BuildContext context) {
    showRoomsSheet(context, onRoomChanged: widget.onRoomChanged);
  }
}
