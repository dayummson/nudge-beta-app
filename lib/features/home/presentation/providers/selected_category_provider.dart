import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../room/domain/entities/category.dart';

/// Notifier for managing selected category filter
class SelectedCategoryNotifier extends Notifier<Category?> {
  @override
  Category? build() => null;

  /// Select a category for filtering
  void selectCategory(Category category) => state = category;

  /// Clear category filter
  void clearCategory() => state = null;
}

/// Provider for managing selected category filter
///
/// Controls which category is currently selected for filtering transactions.
/// Defaults to null (no category filter).
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, Category?>(
      SelectedCategoryNotifier.new,
    );
