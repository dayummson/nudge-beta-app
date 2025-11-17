// app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// Make domain types available to generated part
import 'package:nudge_1/features/room/domain/entities/category.dart';
import 'package:nudge_1/features/room/domain/entities/place_location.dart';
import 'package:nudge_1/features/room/data/local/tables/type_converters.dart';

// Import your tables
import 'package:nudge_1/features/room/data/local/tables/room_members_table.dart';
import 'package:nudge_1/features/room/data/local/tables/rooms_table.dart';
import 'package:nudge_1/features/room/data/local/tables/categories_table.dart';
import 'package:nudge_1/features/room/data/local/tables/expenses_table.dart';
import 'package:nudge_1/features/room/data/local/tables/expense_users_table.dart';
import 'package:nudge_1/features/room/data/local/tables/reactions_table.dart';
import 'package:nudge_1/features/room/data/local/tables/attachments_table.dart';

// Import your DAOs
// DAOs are declared as parts of this library (see files in features/.../dao)

part 'app_database.g.dart';
// Parts: DAOs defined in separate files
part '../../features/room/data/local/dao/rooms_dao.dart';
part '../../features/room/data/local/dao/room_members_dao.dart';
part '../../features/room/data/local/dao/categories_dao.dart';
part '../../features/room/data/local/dao/expenses_dao.dart';
part '../../features/room/data/local/dao/expense_users_dao.dart';
part '../../features/room/data/local/dao/reactions_dao.dart';
part '../../features/room/data/local/dao/attachments_dao.dart';

@DriftDatabase(
  tables: [
    Rooms,
    RoomMembers,
    Categories,
    Expenses,
    Incomes,
    ExpenseUsers,
    Reactions,
    Attachments,
  ],
  daos: [
    RoomsDao,
    RoomMembersDao,
    CategoriesDao,
    ExpensesDao,
    IncomesDao,
    ExpenseUsersDao,
    ReactionsDao,
    AttachmentsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Secondary constructor for tests / CLI tools using an in-memory or custom executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}

// Open connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nudge.sqlite'));
    return NativeDatabase(file);
  });
}
