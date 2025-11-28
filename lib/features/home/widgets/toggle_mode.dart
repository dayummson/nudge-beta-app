import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/constants/categories.dart' as constants;
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import 'package:nudge_1/features/room/domain/entities/transaction.dart';
import 'package:nudge_1/features/room/domain/entities/category.dart' as domain;

// This is change
/// A two-option sliding toggle for Income (left, green) and Expense (right, red).
///
/// Usage:
/// ToggleMode(isExpense: false, onChanged: (v) => ...)
class ToggleMode extends StatefulWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;
  final double expenseTotal;
  final double incomeTotal;
  final double width;
  final double height;

  const ToggleMode({
    super.key,
    required this.isExpense,
    required this.onChanged,
    required this.expenseTotal,
    required this.incomeTotal,
    this.width = 200,
    this.height = 32,
  });

  @override
  State<ToggleMode> createState() => _ToggleModeState();
}

class _ToggleModeState extends State<ToggleMode> {
  late bool _isExpense;
  bool _showQuickAdd = false;
  List<domain.Category> _categories = constants.categories;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final db = AppDatabase();
    final categoryRows = await db.categoriesDao.getAll();

    // Convert database rows to domain categories
    final customCategories = categoryRows.map((row) => row.category).toList();

    // Combine with default categories, filtering out duplicates by id
    final allCategories = [...constants.categories];
    for (final customCategory in customCategories) {
      if (!allCategories.any((cat) => cat.id == customCategory.id)) {
        allCategories.add(customCategory);
      }
    }

    setState(() {
      _categories = allCategories;
    });
  }

  @override
  void didUpdateWidget(covariant ToggleMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpense != oldWidget.isExpense) {
      _isExpense = widget.isExpense;
      _showQuickAdd = false; // Hide quick add when mode changes externally
    }
  }

  void _toggle(bool toExpense) {
    if (toExpense == _isExpense) return;
    setState(() => _isExpense = toExpense);
    widget.onChanged(_isExpense);
  }

  void _toggleQuickAdd() {
    setState(() => _showQuickAdd = !_showQuickAdd);
  }

  Future<void> _addQuickTransaction(double amount) async {
    try {
      final db = AppDatabase();
      final roomId = await RoomSelection.getSelectedRoomId();

      if (roomId == null || roomId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a room first')),
          );
        }
        return;
      }

      // Define expense category IDs
      const expenseCategoryIds = [
        'eatout',
        'transport',
        'shopping',
        'entertainment',
        'bills',
      ];

      // Get the first available category for the current mode
      final categories = _isExpense
          ? _categories
                .where((c) => expenseCategoryIds.contains(c.id))
                .toList()
          : _categories
                .where((c) => !expenseCategoryIds.contains(c.id))
                .toList();

      if (categories.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No categories available')),
          );
        }
        return;
      }

      final category = categories.first;
      final id = 'quick-txn-${DateTime.now().millisecondsSinceEpoch}';

      final companion = TransactionsCompanion(
        id: drift.Value(id),
        roomId: drift.Value(roomId),
        description: drift.Value(_isExpense ? 'Quick expense' : 'Quick income'),
        category: drift.Value(category),
        amount: drift.Value(amount),
        location: const drift.Value(null),
        type: drift.Value(
          _isExpense ? TransactionType.expense : TransactionType.income,
        ),
        hashtags: const drift.Value([]),
        createdAt: drift.Value(DateTime.now()),
      );
      await db.transactionsDao.insert(companion);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quick ${_isExpense ? 'expense' : 'income'} of ₱${amount.toStringAsFixed(2)} added!',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() => _showQuickAdd = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding transaction: $e')));
      }
    }
  }

  Widget _buildQuickAddButton(
    double amount,
    Color expenseColor,
    Color incomeColor,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addQuickTransaction(amount),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isExpense
                ? expenseColor.withOpacity(0.1)
                : incomeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isExpense
                  ? expenseColor.withOpacity(0.3)
                  : incomeColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '₱${amount.toInt()}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _isExpense ? expenseColor : incomeColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fun, playful colors
    final incomeColor = isDark
        ? const Color(0xFF58CC02) // Duolingo green for dark mode
        : const Color(0xFF58CC02); // Duolingo green for light mode
    final expenseColor = isDark
        ? const Color(0xFFFF6B6B) // Coral red for dark mode
        : const Color(0xFFEF5350); // Bright red for light mode

    final textColor = isDark ? Colors.white : Colors.black87;

    return Semantics(
      button: true,
      label:
          'Toggle Expense (left) or Income (right). Long press for quick add.',
      child: GestureDetector(
        onTapDown: (_) => _toggle(!_isExpense),
        onLongPress: _toggleQuickAdd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: widget.width,
          height: _showQuickAdd ? widget.height + 60 : widget.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: widget.width,
                height: widget.height,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.transparent, // Inherit parent background
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Sliding knob (behind labels)
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      alignment: _isExpense
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          height: widget.height - 10,
                          decoration: BoxDecoration(
                            color: _isExpense ? expenseColor : incomeColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: (_isExpense ? expenseColor : incomeColor)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Labels (on top)
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              '- ₱${widget.expenseTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isExpense ? Colors.white : textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '+ ₱${widget.incomeTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: !_isExpense ? Colors.white : textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quick add buttons
              if (_showQuickAdd)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showQuickAdd ? 1.0 : 0.0,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAddButton(10, expenseColor, incomeColor),
                        _buildQuickAddButton(50, expenseColor, incomeColor),
                        _buildQuickAddButton(100, expenseColor, incomeColor),
                        _buildQuickAddButton(500, expenseColor, incomeColor),
                      ],
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
