import "category.dart";
import "place_location.dart";

class Income {
  final String id;
  final String description;
  final Category category;
  final double amount;
  final PlaceLocation? location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Income({
    required this.id,
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
  final String description;
  final Category category;
  final double amount;
  final PlaceLocation? location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Expense({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    this.location,
    required this.createdAt,
    this.updatedAt,
  });
}
