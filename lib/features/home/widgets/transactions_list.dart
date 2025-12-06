import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:ui';
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/core/settings/room_selection.dart';
import 'package:nudge_1/features/room/domain/entities/transaction.dart';
import 'package:nudge_1/features/home/widgets/add_transaction_sheet.dart';
import 'package:nudge_1/firebase/firestore/firestore.dart';
import 'transaction_notification.dart';

class TransactionsList extends StatefulWidget {
  final List<dynamic> transactions; // Can be Expense or Income
  final Color miniTextColor;
  final double totalAmount;
  final VoidCallback? onRoomChanged;

  const TransactionsList({
    super.key,
    required this.transactions,
    required this.miniTextColor,
    required this.totalAmount,
    this.onRoomChanged,
  });

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  final Map<String, int> _userCounts =
      {}; // Cache for user counts per transaction
  final Set<String> _loadingTransactions =
      {}; // Track which transactions are loading

  @override
  void initState() {
    super.initState();
    _loadUserCounts();
  }

  @override
  void didUpdateWidget(TransactionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      _loadUserCounts();
    }
  }

  Future<void> _loadUserCounts() async {
    final db = AppDatabase();

    // Initialize all transactions with count 1 (current user)
    for (final transaction in widget.transactions) {
      if (!_userCounts.containsKey(transaction.id)) {
        _userCounts[transaction.id] = 1;
      }
    }

    // For expenses, check if there are additional users
    for (final transaction in widget.transactions) {
      if (transaction.type == TransactionType.expense) {
        _loadingTransactions.add(transaction.id);
        try {
          final users = await db.expenseUsersDao.getByExpense(transaction.id);
          if (mounted) {
            setState(() {
              // Use the actual count from database, minimum 1
              _userCounts[transaction.id] = users.isNotEmpty ? users.length : 1;
              _loadingTransactions.remove(transaction.id);
            });
          }
        } catch (e) {
          debugPrint(
            'Error loading user count for transaction ${transaction.id}: $e',
          );
          if (mounted) {
            setState(() {
              // Keep the default of 1 on error
              _userCounts[transaction.id] = 1;
              _loadingTransactions.remove(transaction.id);
            });
          }
        }
      }
    }
  }

  // Group transactions by date
  Map<String, List<dynamic>> _groupTransactionsByDate() {
    final Map<String, List<dynamic>> grouped = {};

    for (final transaction in widget.transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.createdAt);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  // Format date for display
  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 100, bottom: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your expenses\nand income here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    final db = AppDatabase();
    final groupedTransactions = _groupTransactionsByDate();
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mini total (tiny text for context while scrolling)
        Padding(
          padding: const EdgeInsets.only(top: 12, left: 20, bottom: 20),
          child: Text(
            "Total: \$${widget.totalAmount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 12, color: widget.miniTextColor),
          ),
        ),

        // Grouped transactions by date with sticky headers
        ...sortedDates.map((dateKey) {
          final dateTransactions = groupedTransactions[dateKey]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: StickyHeader(
              overlapHeaders: false,
              header: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                alignment: Alignment.centerLeft,
                color: Theme.of(context).colorScheme.surface,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _formatDateHeader(dateKey),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.miniTextColor.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              content: Column(
                children: dateTransactions.map((transaction) {
                  final isExpense = transaction.type == TransactionType.expense;
                  final userCount = _userCounts[transaction.id] ?? 1;
                  final isLoading = _loadingTransactions.contains(
                    transaction.id,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Slidable(
                      key: ValueKey(transaction.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        extentRatio: 0.2,
                        children: [
                          CustomSlidableAction(
                            onPressed: (ctx) async {
                              // Show delete confirmation
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Delete Transaction'),
                                  content: const Text(
                                    'Are you sure you want to delete this transaction?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                if (context.mounted) {
                                  FocusScope.of(context).unfocus();
                                }
                                try {
                                  // Delete the transaction from database
                                  final deleteResult = await db.transactionsDao
                                      .deleteById(transaction.id);

                                  print(
                                    'Delete result: $deleteResult rows affected for ${isExpense ? "expense" : "income"} with id: ${transaction.id}',
                                  );

                                  // Sync delete to Firestore
                                  try {
                                    final roomId =
                                        await RoomSelection.getSelectedRoomId();
                                    if (roomId != null && roomId.isNotEmpty) {
                                      await TransactionService()
                                          .deleteTransaction(
                                            roomId: roomId,
                                            transactionId: transaction.id,
                                          );
                                    }
                                  } catch (e) {
                                    // Log error but don't fail the operation - local deletion is preserved
                                    debugPrint(
                                      'Failed to sync transaction delete to Firestore: $e',
                                    );
                                  }

                                  // Show success message
                                  if (context.mounted) {
                                    TransactionNotification.show(
                                      context,
                                      categoryId: transaction.category.id,
                                      amount: transaction.amount,
                                      isExpense: isExpense,
                                      action: 'deleted',
                                    );
                                  }
                                } catch (e) {
                                  print('Error deleting transaction: $e');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error deleting transaction: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF5350),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () {
                          // Open edit sheet when tapping the transaction
                          showAddTransactionSheet(
                            context,
                            onRoomChanged: widget.onRoomChanged,
                            transaction: transaction,
                          );
                        },
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: transaction.category.color.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              transaction.category.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        title: Text(
                          transaction.category.name,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        subtitle:
                            transaction.description.isNotEmpty ||
                                transaction.hashtags.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (transaction.description.isNotEmpty)
                                    Text(
                                      transaction.description,
                                      style: TextStyle(
                                        color: widget.miniTextColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  if (transaction.hashtags.isNotEmpty)
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 2,
                                      children:
                                          (transaction.hashtags as List<String>)
                                              .map(
                                                (tag) => Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Theme.of(
                                                              context,
                                                            ).brightness ==
                                                            Brightness.dark
                                                        ? Colors.grey[850]
                                                        : Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '#$tag',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                ],
                              )
                            : null,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    transaction.runtimeType.toString() ==
                                            'Income'
                                        ? "+"
                                        : "-",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.surface
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                transaction.amount.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // User count indicator
                              if (isLoading)
                                Container(
                                  width: 20,
                                  height: 20,
                                  padding: const EdgeInsets.all(2),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withOpacity(0.8),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.shadow.withOpacity(0.1),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 10,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        userCount == 1 ? '1' : '${userCount}+',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }).toList(),

        // Bottom padding to prevent overlap with floating action buttons
        const SizedBox(height: 90),
      ],
    );
  }
}
