import "category.dart";
import "place_location.dart";

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String description;
  final Category category;
  final double amount;
  final PlaceLocation? location;
  final List<String> hashtags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final TransactionType type;
  final bool isSynced; // offline-first flag
  final DateTime lastUpdatedAt; // fixed type

  const Transaction({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    this.location,
    this.hashtags = const [],
    required this.createdAt,
    this.updatedAt,
    required this.type,
    this.isSynced = false,
    required this.lastUpdatedAt,
  });
}
