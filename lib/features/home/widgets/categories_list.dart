import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/search_enabled_provider.dart';
import '../../../constants/categories.dart' as constants;

class CategoriesList extends ConsumerStatefulWidget {
  final List<dynamic> transactions;
  final double scrollOffset;

  const CategoriesList({
    super.key,
    required this.transactions,
    required this.scrollOffset,
  });

  @override
  ConsumerState<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends ConsumerState<CategoriesList> {
  static const double maxCategoryHeight = 200.0;
  static const double minCategoryHeight = 50.0;

  // Calculate total per category for current transaction list
  Map<String, double> _calculateCategoryTotals() {
    final Map<String, double> totals = {};

    for (final category in constants.categories) {
      totals[category.id] = 0.0;
    }

    // Sum up amounts from the filtered transactions (expense or income)
    for (final transaction in widget.transactions) {
      final categoryId = transaction.category.id;
      totals[categoryId] = (totals[categoryId] ?? 0.0) + transaction.amount;
    }

    return totals;
  }

  double _getMaxCategoryAmount(Map<String, double> categoryTotals) {
    // Find the highest magnitude among all categories (use absolute values)
    final magnitudes = categoryTotals.values
        .map((amount) => amount.abs())
        .where((magnitude) => magnitude > 0);
    return magnitudes.isEmpty
        ? 0.0
        : magnitudes.reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final searchEnabled = ref.watch(searchEnabledProvider);
    final categoryTotals = _calculateCategoryTotals();
    final maxAmount = _getMaxCategoryAmount(categoryTotals);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: searchEnabled ? 0 : maxCategoryHeight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: searchEnabled ? 0 : 1,
        child: searchEnabled
            ? const SizedBox.shrink()
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                itemCount: constants.categories.length,
                itemBuilder: (context, index) {
                  final category = constants.categories[index];
                  final total = categoryTotals[category.id] ?? 0.0;
                  final magnitude = total.abs();

                  // Calculate height based on percentage of MAX magnitude (not grand total)
                  // This makes the tallest category (by absolute value) reach maxHeight
                  final percentage = maxAmount > 0
                      ? (magnitude / maxAmount)
                      : 0.0;
                  final barHeight = magnitude > 0
                      ? (maxCategoryHeight * percentage).clamp(
                          minCategoryHeight,
                          maxCategoryHeight,
                        )
                      : minCategoryHeight;
                  if (kDebugMode) {
                    debugPrint(
                      'Category ${category.id} (${category.name}) -> total: '
                      '${total.toStringAsFixed(2)}, mag: ${magnitude.toStringAsFixed(2)}, '
                      'max: ${maxAmount.toStringAsFixed(2)}, '
                      'pct: ${(percentage * 100).toStringAsFixed(1)}%, '
                      'height: ${barHeight.toStringAsFixed(1)}',
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: barHeight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  category.icon,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${total.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
