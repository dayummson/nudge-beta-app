import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/search_enabled_provider.dart';
import '../presentation/providers/selected_category_provider.dart';
import '../../../constants/categories.dart' as constants;

class CategoriesList extends ConsumerStatefulWidget {
  final List<dynamic> transactions;
  final double scrollOffset;
  final bool hasBothEmptyTransactions;

  const CategoriesList({
    super.key,
    required this.transactions,
    required this.scrollOffset,
    this.hasBothEmptyTransactions = false,
  });

  @override
  ConsumerState<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends ConsumerState<CategoriesList> {
  static const double maxCategoryHeight = 200.0;
  static const double minCategoryHeight = 60.0;

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

  Widget _buildEmptyPlaceholder(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    // Create hierarchical placeholder bars with decreasing heights
    final placeholderHeights = [
      maxCategoryHeight * 0.9,
      maxCategoryHeight * 0.7,
      maxCategoryHeight * 0.5,
      maxCategoryHeight * 0.6,
      maxCategoryHeight * 0.4,
    ];

    return SizedBox.expand(
      child: Stack(
        children: [
          // Placeholder bars - non-scrollable, aligned to bottom
          Align(
            alignment: Alignment.bottomLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: placeholderHeights.map((height) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: height,
                    width: 80,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Centered text message
          Center(
            child: Text(
              'Your transactions will show up here',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchEnabled = ref.watch(searchEnabledProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final categoryTotals = _calculateCategoryTotals();
    final maxAmount = _getMaxCategoryAmount(categoryTotals);
    final showEmptyState = widget.hasBothEmptyTransactions;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sort categories by their total values (descending - highest first)
    final sortedCategories = List.from(constants.categories)
      ..sort((a, b) {
        final aTotal = (categoryTotals[a.id] ?? 0.0).abs();
        final bTotal = (categoryTotals[b.id] ?? 0.0).abs();
        return bTotal.compareTo(aTotal); // Descending order
      });

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: SizedBox(
        height: searchEnabled ? 0 : maxCategoryHeight,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: searchEnabled ? 0 : 1,
          child: searchEnabled
              ? const SizedBox.shrink()
              : showEmptyState
              ? _buildEmptyPlaceholder(context, isDark)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  itemCount: sortedCategories.length,
                  itemBuilder: (context, index) {
                    final category = sortedCategories[index];
                    final total = categoryTotals[category.id] ?? 0.0;
                    final magnitude = total.abs();
                    final isSelected = selectedCategory?.id == category.id;

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
                    // if (kDebugMode) {
                    //   debugPrint(
                    //     'Category ${category.id} (${category.name}) -> total: '
                    //     '${total.toStringAsFixed(2)}, mag: ${magnitude.toStringAsFixed(2)}, '
                    //     'max: ${maxAmount.toStringAsFixed(2)}, '
                    //     'pct: ${(percentage * 100).toStringAsFixed(1)}%, '
                    //     'height: ${barHeight.toStringAsFixed(1)}',
                    //   );
                    // }

                    return GestureDetector(
                      onTap: () {
                        final notifier = ref.read(
                          selectedCategoryProvider.notifier,
                        );
                        if (isSelected) {
                          notifier.clearCategory();
                        } else {
                          notifier.selectCategory(category);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: barHeight,
                            width: 80,
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? category.color.withOpacity(0.8)
                                  : isDark
                                  ? Colors.grey[850]
                                  : Colors.grey[300],

                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(color: category.color, width: 2)
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  category.icon,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Flexible(
                                  child: Text(
                                    magnitude == 0
                                        ? '₱0'
                                        : '₱${total.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
