import "category.dart";

class Income {
  final String id;
  final String title;
  final String description;
  final Category category;
  final double amount;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Income({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    this.location,
    required this.createdAt,
    this.updatedAt,
  });
}

class Expense {
  final String id;
  final String title;
  final String description;
  final Category category;
  final double amount;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Expense({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    this.location,
    required this.createdAt,
    this.updatedAt,
  });
}
