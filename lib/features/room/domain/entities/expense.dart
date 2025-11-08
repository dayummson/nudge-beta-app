import 'expense_user.dart';

class Expense {
  final String id;
  final String title;
  final String description;
  final String category;
  final double amount;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<ExpenseUser> users;

  const Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    this.location,
    required this.createdAt,
    this.updatedAt,
    required this.users,
  });
}
