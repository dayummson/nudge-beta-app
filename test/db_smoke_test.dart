import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/features/room/domain/entities/category.dart' as domain;
// Ensure the bundled sqlite3 is available in tests on desktop
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Drift DB smoke: basic CRUD across DAOs', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    // Rooms
    await db.roomsDao.insertRoom(
      RoomsCompanion(
        id: const Value('room-1'),
        name: const Value('My Room'),
        ownerId: const Value('user-1'),
        isShared: const Value(true),
        users: const Value(['user-1', 'user-2']),
      ),
    );
    final rooms = await db.roomsDao.getAllRooms();
    expect(rooms.length, 1);

    // Categories
    final eatOut = domain.Category(
      id: 'eatout',
      icon: '🍔',
      name: 'Eat out',
      color: const Color(0xFFE53935),
    );

    await db.categoriesDao.upsert(
      CategoriesCompanion(id: const Value('eatout'), category: Value(eatOut)),
    );
    final cats = await db.categoriesDao.getAll();
    expect(cats.length, 1);

    // Expenses
    await db.expensesDao.insert(
      ExpensesCompanion(
        id: const Value('expense-1'),
        description: const Value('Burger dinner'),
        category: Value(eatOut),
        amount: const Value(18.5),
        location: const Value('Downtown'),
      ),
    );
    final exps = await db.expensesDao.getAll();
    expect(exps.length, 1);

    // Incomes
    final salary = domain.Category(
      id: 'salary',
      icon: '💰',
      name: 'Salary',
      color: const Color(0xFF43A047),
    );
    await db.incomesDao.insert(
      IncomesCompanion(
        id: const Value('income-1'),
        description: const Value('Paycheck'),
        category: Value(salary),
        amount: const Value(1500.0),
        location: const Value('Bank'),
      ),
    );
    final incs = await db.incomesDao.getAll();
    expect(incs.length, 1);

    await db.close();
  });
}
