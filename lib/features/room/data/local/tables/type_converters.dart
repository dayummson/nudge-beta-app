import 'package:drift/drift.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/place_location.dart';
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
