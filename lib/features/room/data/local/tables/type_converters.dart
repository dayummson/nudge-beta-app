import 'package:drift/drift.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/place_location.dart';
import '../../../domain/entities/expense.dart';
import 'dart:convert';

/// Shared converter for Category <-> JSON String
class CategoryJsonConverter extends TypeConverter<Category, String> {
  const CategoryJsonConverter();

  @override
  Category fromSql(String fromDb) {
    final Map<String, dynamic> jsonMap = jsonDecode(fromDb);
    return Category.fromJson(jsonMap);
  }

  @override
  String toSql(Category value) {
    return jsonEncode(value.toJson());
  }
}

/// Converter for List<String> <-> JSON String
class HashtagsJsonConverter extends TypeConverter<List<String>, String> {
  const HashtagsJsonConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.map((e) => e as String).toList();
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}

/// Converter for PlaceLocation <-> JSON String
class LocationJsonConverter extends TypeConverter<PlaceLocation, String> {
  const LocationJsonConverter();

  @override
  PlaceLocation fromSql(String fromDb) {
    final Map<String, dynamic> jsonMap = jsonDecode(fromDb);
    return PlaceLocation.fromJson(jsonMap);
  }

  @override
  String toSql(PlaceLocation value) {
    return jsonEncode(value.toJson());
  }
}

/// Converter for TransactionType <-> String
class TransactionTypeConverter extends TypeConverter<TransactionType, String> {
  const TransactionTypeConverter();

  @override
  TransactionType fromSql(String fromDb) {
    return TransactionType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => TransactionType.expense, // default fallback
    );
  }

  @override
  String toSql(TransactionType value) {
    return value.name;
  }
}
