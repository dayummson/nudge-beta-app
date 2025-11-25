import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import '../presentation/providers/transaction_type_provider.dart';

/// Shows the transaction type selection bottom sheet.
///
/// Allows users to filter transactions by type:
/// - Expenses
/// - Income
/// - Income & Expenses
void showTransactionTypeSheet(BuildContext context) {
  showAppBottomSheet(
    context: context,
    title: null,
    mode: SheetMode.auto,
    child: const _TransactionTypeSheetContent(),
  );
}

class _TransactionTypeSheetContent extends ConsumerWidget {
  const _TransactionTypeSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final transactionType = ref.watch(transactionTypeProvider);

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
              'Transaction Type',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: TransactionType.values.map((type) {
                final isSelected = transactionType == type;
                final label = type == TransactionType.expense
                    ? 'Expenses'
                    : type == TransactionType.income
                    ? 'Income'
                    : 'Income & Expenses';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(transactionTypeProvider.notifier)
                          .setTransactionType(type);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: isSelected
                          ? cs.primary.withOpacity(0.1)
                          : Colors.transparent,
                      side: BorderSide(
                        color: isSelected
                            ? cs.primary
                            : cs.onSurface.withOpacity(0.12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check, color: cs.primary, size: 20),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
