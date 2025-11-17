import 'package:drift/drift.dart';
import '../../../domain/entities/category.dart';
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
