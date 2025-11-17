import 'package:drift/drift.dart';
import 'dart:convert';

class ReactionCountsConverter extends TypeConverter<Map<String, int>, String> {
  const ReactionCountsConverter();

  @override
  Map<String, int> fromSql(String fromDb) {
    if (fromDb.isEmpty) return {};
    final Map<String, dynamic> map = jsonDecode(fromDb);
    return map.map((key, value) => MapEntry(key, value as int));
  }

  @override
  String toSql(Map<String, int>? value) {
    if (value == null || value.isEmpty) return '{}';
    return jsonEncode(value);
  }
}

/// Drift table for attachments
class Attachments extends Table {
  TextColumn get id => text()(); // primary key
  TextColumn get url => text()();
  TextColumn get type => text()(); // e.g., "image", "pdf"
  TextColumn get uploadedBy => text()(); // userId
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get reactionCounts =>
      text().map(const ReactionCountsConverter())(); // JSON stored map

  @override
  Set<Column> get primaryKey => {id};
}
