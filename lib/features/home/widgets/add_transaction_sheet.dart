import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import 'package:nudge_1/constants/categories.dart' as constants;
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import 'action_buttons_section.dart';
import 'amount_input_section.dart';
import 'category_selection_section.dart';
import 'date_selector_button.dart';
import 'room_selector_button.dart';

/// Shows the add transaction bottom sheet.
///
/// Allows users to:
/// - Enter description and amount
/// - Toggle between expense/income
/// - Select a category
/// - Add tags
/// - Save the transaction
///
/// If [transaction] is provided, the sheet will be in edit mode.
void showAddTransactionSheet(
  BuildContext context, {
  VoidCallback? onRoomChanged,
  dynamic transaction,
}) {
  showAppBottomSheet(
    context: context,
    mode: SheetMode.auto,
    child: _AddTransactionSheetContent(
      onRoomChanged: onRoomChanged,
      transaction: transaction,
    ),
  );
}

class _AddTransactionSheetContent extends StatefulWidget {
  final VoidCallback? onRoomChanged;
  final dynamic transaction; // Expense or Income for editing

  const _AddTransactionSheetContent({this.onRoomChanged, this.transaction});

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
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with transaction data
    if (widget.transaction != null) {
      final txn = widget.transaction;
      _descriptionController.text = txn.description ?? '';
      _amountController.text = txn.amount.toString();
      _selectedCategoryId = txn.category.id;
      _isExpense = txn.runtimeType.toString() == 'Expense';
    }
  }

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
      final db = AppDatabase();

      final isEditing = widget.transaction != null;
      final id = isEditing
          ? widget.transaction.id
          : 'txn-${DateTime.now().millisecondsSinceEpoch}';

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
        final companion = ExpensesCompanion(
          id: drift.Value(id),
          roomId: drift.Value(roomId),
          description: drift.Value(description),
          category: drift.Value(category),
          amount: drift.Value(amount),
          location: const drift.Value(null),
          createdAt: drift.Value(
            isEditing ? widget.transaction.createdAt : DateTime.now(),
          ),
        );

        if (isEditing) {
          await db.expensesDao.updateEntry(companion);
        } else {
          await db.expensesDao.insert(companion);
        }
      } else {
        final companion = IncomesCompanion(
          id: drift.Value(id),
          roomId: drift.Value(roomId),
          description: drift.Value(description),
          category: drift.Value(category),
          amount: drift.Value(amount),
          location: const drift.Value(null),
          createdAt: drift.Value(
            isEditing ? widget.transaction.createdAt : DateTime.now(),
          ),
        );

        if (isEditing) {
          await db.incomesDao.updateEntry(companion);
        } else {
          await db.incomesDao.insert(companion);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_isExpense ? 'Expense' : 'Income'} ${isEditing ? 'updated' : 'saved'} successfully',
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Room and Date selector buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              RoomSelectorButton(onRoomChanged: widget.onRoomChanged),
              const SizedBox(width: 12),
              DateSelectorButton(
                selectedDate: _selectedDate,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AmountInputSection(
          descriptionController: _descriptionController,
          amountController: _amountController,
          inlineAmountFocusNode: _inlineAmountFocusNode,
          isExpense: _isExpense,
          onExpenseChanged: (isExpense) =>
              setState(() => _isExpense = isExpense),
        ),
        const SizedBox(height: 16),
        CategorySelectionSection(
          selectedCategoryId: _selectedCategoryId,
          onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
          isExpense: _isExpense,
        ),
        const SizedBox(height: 16),
        ActionButtonsSection(isSaving: _isSaving, onSave: _saveTransaction),
      ],
    );
  }
}
