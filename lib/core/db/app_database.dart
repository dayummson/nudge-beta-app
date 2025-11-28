// app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// Make domain types available to generated part
import 'package:nudge_1/features/room/domain/entities/category.dart';
import 'package:nudge_1/features/room/domain/entities/place_location.dart';
import 'package:nudge_1/features/room/domain/entities/transaction.dart';
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
    Transactions,
    ExpenseUsers,
    Reactions,
    Attachments,
  ],
  daos: [
    RoomsDao,
    RoomMembersDao,
    CategoriesDao,
    TransactionsDao,
    ExpenseUsersDao,
    ReactionsDao,
    AttachmentsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // Singleton pattern
  static final AppDatabase _instance = AppDatabase._internal();

  factory AppDatabase() {
    return _instance;
  }

  AppDatabase._internal() : super(_openConnection());

  // Secondary constructor for tests / CLI tools using an in-memory or custom executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from == 1) {
        // Migrate from separate expenses/incomes tables to unified transactions table
        // This is a major schema change, so we recreate the tables
        await m.deleteTable('expenses');
        await m.deleteTable('incomes');
        await m.createTable(transactions);
      }
      if (from < 4) {
        // Ensure transactions table has all required columns
        await m.deleteTable(transactions.actualTableName);
        await m.createTable(transactions);
      }
    },
  );
}

// Open connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'nudge.sqlite'));
    return NativeDatabase(file);
  });
}
