import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:nudge_1/core/db/app_database.dart';
import 'package:nudge_1/features/room/domain/entities/category.dart' as domain;
import 'package:nudge_1/features/room/domain/entities/place_location.dart';

class DebugDbScreen extends StatefulWidget {
  const DebugDbScreen({super.key});

  @override
  State<DebugDbScreen> createState() => _DebugDbScreenState();
}

class _DebugDbScreenState extends State<DebugDbScreen> {
  late final AppDatabase db;

  String log = '';

  @override
  void initState() {
    super.initState();
    db = AppDatabase();
  }

  void _append(String line) {
    setState(() {
      log = '${DateTime.now().toIso8601String()}  $line\n$log';
    });
  }

  Future<void> _seedSample() async {
    try {
      // Room
      await db.roomsDao.insertRoom(
        RoomsCompanion(
          id: const drift.Value('room-debug'),
          name: const drift.Value('Debug Room'),
          ownerId: const drift.Value('user-debug'),
          isShared: const drift.Value(true),
          users: const drift.Value(['user-debug']),
        ),
      );
      _append('Inserted room room-debug');

      // Categories
      final eatout = domain.Category(
        id: 'eatout',
        icon: '🍔',
        name: 'Eat out',
        color: const Color(0xFFE53935),
      );
      await db.categoriesDao.upsert(
        CategoriesCompanion(
          id: const drift.Value('eatout'),
          category: drift.Value(eatout),
        ),
      );
      _append('Upserted category eatout');

      // Expense
      await db.expensesDao.insert(
        ExpensesCompanion(
          id: const drift.Value('expense-debug-1'),
          description: const drift.Value('Burger dinner'),
          category: drift.Value(eatout),
          amount: const drift.Value(18.5),
          location: const drift.Value(
            PlaceLocation(
              address: '1600 Amphitheatre Parkway',
              lat: 37.422,
              lng: -122.084,
            ),
          ),
        ),
      );
      _append('Inserted expense expense-debug-1');

      // Income
      final salary = domain.Category(
        id: 'salary',
        icon: '💰',
        name: 'Salary',
        color: const Color(0xFF43A047),
      );
      await db.incomesDao.insert(
        IncomesCompanion(
          id: const drift.Value('income-debug-1'),
          description: const drift.Value('Paycheck'),
          category: drift.Value(salary),
          amount: const drift.Value(1500.0),
          location: const drift.Value(
            PlaceLocation(
              address: '1 Market St, San Francisco',
              lat: 37.7936,
              lng: -122.3958,
            ),
          ),
        ),
      );
      _append('Inserted income income-debug-1');
    } catch (e) {
      _append('Seed error: $e');
    }
  }

  Future<void> _loadAll() async {
    try {
      final rooms = await db.roomsDao.getAllRooms();
      final cats = await db.categoriesDao.getAll();
      final exps = await db.expensesDao.getAll();
      final incs = await db.incomesDao.getAll();

      _append('Rooms(${rooms.length}):');
      for (final r in rooms) {
        _append(
          ' - ${r.id} | name: ${r.name} | owner: ${r.ownerId} | users: ${r.users}',
        );
      }

      _append('Categories(${cats.length}):');
      for (final c in cats) {
        final cat = c.category; // domain.Category
        final colorHex = cat.color.value.toRadixString(16).padLeft(8, '0');
        _append(
          ' - ${c.id} | name: ${cat.name} | icon: ${cat.icon} | color: 0x$colorHex',
        );
      }

      _append('Expenses(${exps.length}):');
      for (final e in exps) {
        final cat = e.category; // domain.Category
        final loc = e.location;
        final locStr = loc == null
            ? ''
            : '${loc.address} (lat: ${loc.lat}, lng: ${loc.lng})';
        _append(
          ' - ${e.id} | ${e.description} | amount: ${e.amount} | '
          'category: ${cat.name} (${cat.id}) | location: $locStr',
        );
      }

      _append('Incomes(${incs.length}):');
      for (final i in incs) {
        final cat = i.category; // domain.Category
        final loc = i.location;
        final locStr = loc == null
            ? ''
            : '${loc.address} (lat: ${loc.lat}, lng: ${loc.lng})';
        _append(
          ' - ${i.id} | ${i.description} | amount: ${i.amount} | '
          'category: ${cat.name} (${cat.id}) | location: $locStr',
        );
      }
    } catch (e) {
      _append('Load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Debug DB')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Seed sample'),
                  onPressed: _seedSample,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load all'),
                  onPressed: _loadAll,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cs.surfaceVariant.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outline.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    log.isEmpty ? 'No logs yet. Use buttons above.' : log,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
