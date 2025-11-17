import 'package:drift/drift.dart';

class Reactions extends Table {
  TextColumn get id => text()(); // primary key
  TextColumn get type => text().map(const ReactionTypeConverter())();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)(); // default timestamp

  @override
  Set<Column> get primaryKey => {id};
}

enum ReactionType { like, love, sad, haha, wow }

class ReactionTypeConverter extends TypeConverter<ReactionType, String> {
  const ReactionTypeConverter();

  @override
  ReactionType fromSql(String fromDb) {
    return ReactionType.values.firstWhere(
      (e) => e.name == fromDb,
      orElse: () => ReactionType.like,
    );
  }

  @override
  String toSql(ReactionType value) => value.name;
}
