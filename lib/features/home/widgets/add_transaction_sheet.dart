import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import 'package:nudge_1/constants/categories.dart' as constants;
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import 'package:nudge_1/features/room/domain/entities/transaction.dart';
import 'action_buttons_section.dart';
import 'amount_input_section.dart';
import 'category_selection_section.dart';
import 'date_selector_button.dart';
import 'room_selector_button.dart';
import 'transaction_notification.dart';
import 'frequency_sheet.dart';

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
  final _hashtagController = TextEditingController();
  bool _isExpense = true;
  bool _isHashtagsExpanded = false;
  String? _selectedCategoryId;
  late DateTime _selectedDate;
  bool _isSaving = false;
  List<String> _hashtags = [];

  @override
  void initState() {
    super.initState();
    // Initialize selected date to current date at midnight
    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    // If editing, populate fields with transaction data
    if (widget.transaction != null) {
      final txn = widget.transaction;
      _descriptionController.text = txn.description ?? '';
      _amountController.text = txn.amount.toString();
      _selectedCategoryId = txn.category.id;
      _isExpense = txn.type == TransactionType.expense;
      _selectedDate = txn.createdAt;
      _hashtags = txn.hashtags ?? [];
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _inlineAmountFocusNode.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;

    // Check if there's any pending hashtag text and add it to the list
    final pendingHashtag = _hashtagController.text.trim();
    if (pendingHashtag.isNotEmpty && !_hashtags.contains(pendingHashtag)) {
      _hashtags.add(pendingHashtag);
    }

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

      final companion = TransactionsCompanion(
        id: drift.Value(id),
        roomId: drift.Value(roomId),
        description: drift.Value(description),
        category: drift.Value(category),
        amount: drift.Value(amount),
        location: const drift.Value(null),
        hashtags: drift.Value(_hashtags),
        type: drift.Value(
          _isExpense ? TransactionType.expense : TransactionType.income,
        ),
        createdAt: drift.Value(_selectedDate),
      );

      if (isEditing) {
        // Update existing transaction
        await db.transactionsDao.updateEntry(companion);
      } else {
        // Insert new transaction
        await db.transactionsDao.insert(companion);
      }

      if (mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.pop(context);
        TransactionNotification.show(
          context,
          categoryId: category.id,
          amount: amount,
          isExpense: _isExpense,
          action: isEditing ? 'updated' : 'created',
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
              _FrequencySelectorButton(),
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
        ActionButtonsSection(
          isSaving: _isSaving,
          onSave: _saveTransaction,
          onHashtag: () => setState(() => _isHashtagsExpanded = true),
          isExpanded: _isHashtagsExpanded,
          hashtags: _hashtags,
          hashtagController: _hashtagController,
          onHashtagSubmit: (value) {
            setState(() {
              _hashtags.add(value);
              _hashtagController.clear();
            });
          },
          onCollapse: () => setState(() => _isHashtagsExpanded = false),
          onRemoveHashtag: (tag) {
            setState(() {
              _hashtags.remove(tag);
            });
          },
        ),
        const SizedBox(
          height: 20,
        ), // Add space to avoid keyboard covering bottom
      ],
    );
  }
}

class _FrequencySelectorButton extends StatelessWidget {
  const _FrequencySelectorButton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: () {
        showFrequencySheet(
          context,
          onFrequencySelected: (frequency) {
            // TODO: Handle frequency selection
            print('Selected frequency: ${frequency.displayName}');
          },
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: const StadiumBorder(),
        side: BorderSide(color: colorScheme.onSurface.withOpacity(0.2)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Once',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.unfold_more, size: 18, color: colorScheme.onSurface),
        ],
      ),
    );
  }
}
