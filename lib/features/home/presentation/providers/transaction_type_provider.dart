import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TransactionType { expense, income, both }

/// Notifier for managing transaction type filter state
class TransactionTypeNotifier extends Notifier<TransactionType> {
  @override
  TransactionType build() => TransactionType.both;

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
/// Controls whether to show expense, income, or both transactions when search is active.
/// Defaults to both.
final transactionTypeProvider =
    NotifierProvider<TransactionTypeNotifier, TransactionType>(
      TransactionTypeNotifier.new,
    );
