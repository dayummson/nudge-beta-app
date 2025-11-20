import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import 'package:nudge_1/constants/categories.dart' as constants;
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import 'package:nudge_1/features/room/widgets/rooms_sheet.dart';

/// Shows the add transaction bottom sheet.
///
/// Allows users to:
/// - Enter description and amount
/// - Toggle between expense/income
/// - Select a category
/// - Add tags
/// - Save the transaction
void showAddTransactionSheet(BuildContext context) {
  showAppBottomSheet(
    context: context,
    mode: SheetMode.auto,
    child: const _AddTransactionSheetContent(),
  );
}

class _AddTransactionSheetContent extends StatefulWidget {
  const _AddTransactionSheetContent();

  @override
  State<_AddTransactionSheetContent> createState() =>
      _AddTransactionSheetContentState();
}

class _AddTransactionSheetContentState
    extends State<_AddTransactionSheetContent> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _inlineAmountFocusNode = FocusNode();
  bool _isExpense = true;
  String? _selectedCategoryId;
  bool _isSaving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _inlineAmountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
      }
      return;
    }

    if (_selectedCategoryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final category = constants.categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
      );
      final description = _descriptionController.text.trim();
      final id = 'txn-${DateTime.now().millisecondsSinceEpoch}';
      final db = AppDatabase();

      // Get current selected room ID
      final roomId = await RoomSelection.getSelectedRoomId();
      if (roomId == null || roomId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a room first')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      if (_isExpense) {
        await db.expensesDao.insert(
          ExpensesCompanion(
            id: drift.Value(id),
            roomId: drift.Value(roomId),
            description: drift.Value(description),
            category: drift.Value(category),
            amount: drift.Value(amount),
            location: const drift.Value(null),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
      } else {
        await db.incomesDao.insert(
          IncomesCompanion(
            id: drift.Value(id),
            roomId: drift.Value(roomId),
            description: drift.Value(description),
            category: drift.Value(category),
            amount: drift.Value(amount),
            location: const drift.Value(null),
            createdAt: drift.Value(DateTime.now()),
          ),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_isExpense ? 'Expense' : 'Income'} saved successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = cs.onSurface.withOpacity(0.5);
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;
    final incomeColor = const Color(0xFF58CC02);
    final expenseColor = isDark
        ? const Color(0xFFFF6B6B)
        : const Color(0xFFEF5350);

    Widget field(TextEditingController c, String hint, {TextInputType? type}) =>
        TextField(
          controller: c,
          keyboardType: type,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: 0.2,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        );

    Widget toggle() {
      const w = 88.0;
      const h = 36.0;
      final activeColor = _isExpense ? expenseColor : incomeColor;
      return GestureDetector(
        onTapDown: (d) {
          final toExpense = d.localPosition.dx < (w / 2);
          if (toExpense != _isExpense) {
            setState(() => _isExpense = toExpense);
          }
        },
        child: Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: _isExpense
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: h - 10,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isExpense
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: !_isExpense
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Room selector button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ValueListenableBuilder<String?>(
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
                      onPressed: () => showRoomsSheet(context),
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
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: field(_descriptionController, 'Description'),
        ),
        const SizedBox(height: 2),
        // Show top amount input only when there's no amount typed yet.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _amountController,
          builder: (context, val, _) {
            final empty = val.text.trim().isEmpty;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: empty
                  ? Padding(
                      key: const ValueKey('topAmountField'),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: field(
                        _amountController,
                        'Amount',
                        type: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    )
                  : const SizedBox(key: ValueKey('topAmountHidden')),
            );
          },
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _amountController,
          builder: (context, value, _) {
            final show = value.text.trim().isNotEmpty;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide =
                    Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    );
                return ClipRect(
                  child: SlideTransition(
                    position: slide,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                );
              },
              child: show
                  ? Padding(
                      key: const ValueKey('amountRow'),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          toggle(),
                          const SizedBox(width: 12),
                          // Inline editable amount field that takes focus when shown
                          Expanded(
                            child: Builder(
                              builder: (ctx) {
                                // Request focus when the inline field appears
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!_inlineAmountFocusNode.hasFocus) {
                                    _amountController
                                        .selection = TextSelection.fromPosition(
                                      TextPosition(
                                        offset: _amountController.text.length,
                                      ),
                                    );
                                    _inlineAmountFocusNode.requestFocus();
                                  }
                                });

                                return TextField(
                                  controller: _amountController,
                                  focusNode: _inlineAmountFocusNode,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: _isExpense
                                        ? expenseColor
                                        : incomeColor,
                                    height: 1,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: '₱ ',
                                    prefixStyle: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: _isExpense
                                          ? expenseColor
                                          : incomeColor,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(key: ValueKey('emptyRow')),
            );
          },
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final isCollapsed = child.key == const ValueKey('chipsCollapsed');
            final beginOffset = isCollapsed
                ? const Offset(0.3, 0)
                : const Offset(-0.2, 0);
            final slide = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: _selectedCategoryId == null
              ? SingleChildScrollView(
                  key: const ValueKey('chipsFull'),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          shape: const StadiumBorder(),
                          side: BorderSide(color: borderColor),
                          backgroundColor: cs.surfaceVariant,
                          foregroundColor: cs.onSurfaceVariant,
                        ),
                        child: const Icon(Icons.add, size: 18),
                      ),
                      const SizedBox(width: 8),
                      ...constants.categories.map((cat) {
                        final selected = cat.id == _selectedCategoryId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: selected,
                            onSelected: (val) => setState(
                              () => _selectedCategoryId = val ? cat.id : null,
                            ),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cat.icon,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(cat.name),
                                if (selected) ...[
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: cs.onSurface,
                                  ),
                                ],
                              ],
                            ),
                            shape: const StadiumBorder(),
                            side: BorderSide(
                              color: selected ? cs.primary : borderColor,
                            ),
                            backgroundColor: Colors.transparent,
                            selectedColor: cs.surface.withOpacity(0.06),
                            labelStyle: TextStyle(
                              color: selected ? cs.onSurface : cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }).toList(),
                      const SizedBox(width: 16),
                    ],
                  ),
                )
              : Padding(
                  key: const ValueKey('chipsCollapsed'),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      ChoiceChip(
                        selected: true,
                        onSelected: (_) =>
                            setState(() => _selectedCategoryId = null),
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              constants.categories
                                  .firstWhere(
                                    (c) => c.id == _selectedCategoryId,
                                  )
                                  .icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              constants.categories
                                  .firstWhere(
                                    (c) => c.id == _selectedCategoryId,
                                  )
                                  .name,
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right,
                              size: 18,
                              color: cs.onSurface,
                            ),
                          ],
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide(color: cs.primary),
                        backgroundColor: Colors.transparent,
                        selectedColor: cs.surface.withOpacity(0.06),
                        labelStyle: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _selectedCategoryId == null
              ? Padding(
                  key: const ValueKey('actionsFull'),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: cs.surfaceVariant,
                          side: BorderSide(color: borderColor),
                          foregroundColor: cs.onSurfaceVariant,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('#'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 18, color: cs.onPrimary),
                              const SizedBox(width: 8),
                              const Text('Save'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  key: const ValueKey('actionsCollapsed'),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: cs.surfaceVariant,
                          side: BorderSide(color: borderColor),
                          foregroundColor: cs.onSurfaceVariant,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('#'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveTransaction,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: _isSaving
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onPrimary,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      size: 18,
                                      color: cs.onPrimary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Save'),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
