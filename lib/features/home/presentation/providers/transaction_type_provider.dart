import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TransactionType { expense, income }

/// Notifier for managing transaction type filter state
class TransactionTypeNotifier extends Notifier<TransactionType> {
  @override
  TransactionType build() => TransactionType.expense;

  /// Set transaction type
  void setTransactionType(TransactionType type) => state = type;

  /// Toggle between expense and income
  void toggle() {
    state = state == TransactionType.expense
        ? TransactionType.income
        : TransactionType.expense;
  }
}

/// Provider for managing transaction type filter state
///
/// Controls whether to show expense or income transactions when search is active.
/// Defaults to expense.
final transactionTypeProvider =
    NotifierProvider<TransactionTypeNotifier, TransactionType>(
      TransactionTypeNotifier.new,
    );
