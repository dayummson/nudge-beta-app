import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/features/room/domain/entities/category.dart' as domain;
import 'package:nudge_1/features/room/domain/entities/place_location.dart';
import 'package:nudge_1/features/room/domain/entities/expense.dart';

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

    // Transactions
    await db.transactionsDao.insert(
      TransactionsCompanion(
        id: const Value('expense-1'),
        roomId: const Value('room-1'),
        description: const Value('Burger dinner'),
        category: Value(eatOut),
        amount: const Value(18.5),
        location: const Value(
          PlaceLocation(
            address: '1600 Amphitheatre Parkway',
            lat: 37.422,
            lng: -122.084,
          ),
        ),
        type: const Value(TransactionType.expense),
        hashtags: const Value([]),
        createdAt: Value(DateTime.now()),
      ),
    );
    final exps = await db.transactionsDao.getAll();
    expect(exps.length, 1);

    // Incomes
    final salary = domain.Category(
      id: 'salary',
      icon: '💰',
      name: 'Salary',
      color: const Color(0xFF43A047),
    );
    await db.transactionsDao.insert(
      TransactionsCompanion(
        id: const Value('income-1'),
        roomId: const Value('room-1'),
        description: const Value('Paycheck'),
        category: Value(salary),
        amount: const Value(1500.0),
        location: const Value(
          PlaceLocation(
            address: '1 Market St, San Francisco',
            lat: 37.7936,
            lng: -122.3958,
          ),
        ),
        type: const Value(TransactionType.income),
        hashtags: const Value([]),
        createdAt: Value(DateTime.now()),
      ),
    );
    final incs = await db.transactionsDao.getAll();
    expect(incs.length, 2); // Both expense and income

    await db.close();
  });
}
