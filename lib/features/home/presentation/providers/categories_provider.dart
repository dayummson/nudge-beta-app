import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../constants/categories.dart' as constants;
import '../../../../../core/db/app_database.dart';
import '../../../room/domain/entities/category.dart' as domain;

/// Notifier for managing categories list
class CategoriesNotifier extends Notifier<List<domain.Category>> {
  @override
  List<domain.Category> build() {
    // Return default categories initially, then load from database
    _loadCategories();
    return constants.categories;
  }

  Future<void> _loadCategories() async {
    final db = AppDatabase();
    final categoryRows = await db.categoriesDao.getAll();

    // Convert database rows to domain categories
    final customCategories = categoryRows.map((row) => row.category).toList();

    // Combine with default categories, filtering out duplicates by id
    final allCategories = [...constants.categories];
    for (final customCategory in customCategories) {
      if (!allCategories.any((cat) => cat.id == customCategory.id)) {
        allCategories.add(customCategory);
      }
    }

    state = allCategories;
  }

  /// Refresh categories from database
  Future<void> refreshCategories() async {
    await _loadCategories();
  }
}

/// Provider for managing categories list
///
/// Provides the combined list of default and custom categories.
/// Automatically loads from database on initialization and provides refresh capability.
final categoriesProvider =
    NotifierProvider<CategoriesNotifier, List<domain.Category>>(
      CategoriesNotifier.new,
    );
