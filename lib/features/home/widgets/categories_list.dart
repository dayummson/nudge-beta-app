import 'package:flutter/material.dart';
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

class _CategoriesListState extends ConsumerState<CategoriesList>
    with SingleTickerProviderStateMixin {
  static const double minBarHeight = 120.0;
  static const double maxBarHeight = 250.0;
  static const double compactHeight = 50.0;
  double currentHeight = minBarHeight;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  // Calculate total per category
  Map<String, double> _calculateCategoryTotals() {
    final Map<String, double> totals = {};

    for (final category in constants.categories) {
      totals[category.id] = 0.0;
    }

    for (final transaction in widget.transactions) {
      final categoryId = transaction.category.id;
      totals[categoryId] = (totals[categoryId] ?? 0.0) + transaction.amount;
    }

    return totals;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Dragging up (negative delta) increases height
      // Dragging down (positive delta) decreases height
      currentHeight = (currentHeight - details.delta.dy).clamp(
        minBarHeight,
        maxBarHeight,
      );
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // No bounce-back animation - let user control the height
    // Height stays where the user left it
  }

  @override
  Widget build(BuildContext context) {
    final searchEnabled = ref.watch(searchEnabledProvider);
    final categoryTotals = _calculateCategoryTotals();
    final isScrolled = widget.scrollOffset > 50;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: searchEnabled ? 0 : (isScrolled ? compactHeight : currentHeight),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: searchEnabled ? 0 : 1,
        child: searchEnabled
            ? const SizedBox.shrink()
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragStart: isScrolled
                    ? null
                    : (details) {
                        // Prevent parent scroll from receiving drag events
                      },
                onVerticalDragUpdate: isScrolled ? null : _onVerticalDragUpdate,
                onVerticalDragEnd: isScrolled ? null : _onVerticalDragEnd,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: constants.categories.length,
                  itemBuilder: (context, index) {
                    final category = constants.categories[index];
                    final total = categoryTotals[category.id] ?? 0.0;

                    if (isScrolled) {
                      // Compact horizontal layout: Icon on left, Amount on right
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.icon,
                              style: const TextStyle(fontSize: 20, height: 1.0),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${total.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Vertical layout: Icon on top, Amount below
                      // Natural sizing - no dynamic height calculation
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 60,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  category.icon,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    height: 1.0,
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
                    }
                  },
                ),
              ),
      ),
    );
  }
}
