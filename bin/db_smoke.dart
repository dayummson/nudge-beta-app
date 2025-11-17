import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/features/room/domain/entities/category.dart' as domain;
import 'package:nudge_1/features/room/domain/entities/place_location.dart';

Future<void> main() async {
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
  print('Rooms: ${rooms.length} -> ${rooms.map((r) => r.id).toList()}');

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
  print('Categories: ${cats.length} -> ${cats.map((c) => c.id).toList()}');

  // Expenses
  await db.expensesDao.insert(
    ExpensesCompanion(
      id: const Value('expense-1'),
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
    ),
  );
  final exps = await db.expensesDao.getAll();
  print('Expenses: ${exps.length} -> ${exps.map((e) => e.id).toList()}');

  // Incomes
  await db.incomesDao.insert(
    IncomesCompanion(
      id: const Value('income-1'),
      description: const Value('Paycheck'),
      category: Value(
        domain.Category(
          id: 'salary',
          icon: '💰',
          name: 'Salary',
          color: const Color(0xFF43A047),
        ),
      ),
      amount: const Value(1500.0),
      location: const Value(
        PlaceLocation(
          address: '1 Market St, San Francisco',
          lat: 37.7936,
          lng: -122.3958,
        ),
      ),
    ),
  );
  final incs = await db.incomesDao.getAll();
  print('Incomes: ${incs.length} -> ${incs.map((i) => i.id).toList()}');

  await db.close();
}
