import 'package:flutter/material.dart';
import 'package:nudge_1/constants/categories.dart' as constants;
import '../../../core/db/app_database.dart';
import '../../../features/room/domain/entities/category.dart' as domain;
import '../../categories/widgets/categories_sheet.dart';

class CategorySelectionSection extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;
  final bool isExpense;

  const CategorySelectionSection({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.isExpense,
  });

  @override
  State<CategorySelectionSection> createState() =>
      _CategorySelectionSectionState();
}

class _CategorySelectionSectionState extends State<CategorySelectionSection> {
  List<domain.Category> _categories = constants.categories;

  @override
  void initState() {
    super.initState();
    _loadCategories();
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

    setState(() {
      _categories = allCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final incomeColor = const Color(0xFF58CC02);
    final expenseColor = isDark
        ? const Color(0xFFFF6B6B)
        : const Color(0xFFEF5350);

    return SizedBox(
      height: 48,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final isCollapsed = child.key == const ValueKey('chipsCollapsed');
          final beginOffset = isCollapsed
              ? const Offset(0.3, 0)
              : const Offset(-0.2, 0);
          final slide = Tween<Offset>(
            begin: beginOffset,
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: widget.selectedCategoryId == null
            ? SingleChildScrollView(
                key: const ValueKey('chipsFull'),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => showCategoriesSheet(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide(color: borderColor),
                        backgroundColor: cs.surfaceVariant,
                        foregroundColor: cs.onSurfaceVariant,
                      ),
                      child: const Icon(Icons.add, size: 18),
                    ),
                    const SizedBox(width: 8),
                    ..._categories.map((cat) {
                      final selected = cat.id == widget.selectedCategoryId;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: selected,
                          onSelected: (val) =>
                              widget.onCategorySelected(val ? cat.id : null),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                cat.icon,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Text(cat.name),
                              if (selected) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: cs.onSurface,
                                ),
                              ],
                            ],
                          ),
                          shape: const StadiumBorder(),
                          side: BorderSide(
                            color: selected
                                ? (widget.isExpense
                                      ? expenseColor
                                      : incomeColor)
                                : borderColor,
                          ),
                          backgroundColor: Colors.transparent,
                          selectedColor: cs.surface.withOpacity(0.06),
                          labelStyle: TextStyle(
                            color: selected ? cs.onSurface : cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          showCheckmark: false,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      );
                    }).toList(),
                    const SizedBox(width: 8),
                  ],
                ),
              )
            : Padding(
                key: const ValueKey('chipsCollapsed'),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    ChoiceChip(
                      selected: true,
                      onSelected: (_) => widget.onCategorySelected(null),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _categories
                                .firstWhere(
                                  (c) => c.id == widget.selectedCategoryId,
                                )
                                .icon,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _categories
                                .firstWhere(
                                  (c) => c.id == widget.selectedCategoryId,
                                )
                                .name,
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: cs.onSurface,
                          ),
                        ],
                      ),
                      showCheckmark: false,
                      shape: const StadiumBorder(),
                      side: BorderSide(
                        color: widget.isExpense ? expenseColor : incomeColor,
                      ),
                      backgroundColor: Colors.transparent,
                      selectedColor: cs.surface.withOpacity(0.06),
                      labelStyle: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
