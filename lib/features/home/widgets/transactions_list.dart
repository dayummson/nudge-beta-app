import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:ui';
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/features/home/widgets/add_transaction_sheet.dart';

class TransactionsList extends StatelessWidget {
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

  // Group transactions by date
  Map<String, List<dynamic>> _groupTransactionsByDate() {
    final Map<String, List<dynamic>> grouped = {};

    for (final transaction in transactions) {
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
    if (transactions.isEmpty) {
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
            "Total: \$${totalAmount.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 12, color: miniTextColor),
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
                          color: miniTextColor.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              content: Column(
                children: dateTransactions.map((transaction) {
                  final isExpense =
                      transaction.runtimeType.toString() == 'Expense';

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
                                  final deleteResult = isExpense
                                      ? await db.expensesDao.deleteById(
                                          transaction.id,
                                        )
                                      : await db.incomesDao.deleteById(
                                          transaction.id,
                                        );

                                  print(
                                    'Delete result: $deleteResult rows affected for ${isExpense ? "expense" : "income"} with id: ${transaction.id}',
                                  );

                                  // Show success message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Transaction deleted'),
                                        duration: Duration(seconds: 1),
                                      ),
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
                            onRoomChanged: onRoomChanged,
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
                        subtitle: transaction.description.isNotEmpty
                            ? Text(
                                transaction.description,
                                style: TextStyle(
                                  color: miniTextColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
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
