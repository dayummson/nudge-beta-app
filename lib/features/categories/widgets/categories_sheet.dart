import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import 'package:nudge_1/constants/categories.dart';
import 'package:nudge_1/features/room/domain/entities/category.dart' as domain;
import 'package:nudge_1/core/db/app_database.dart';
import 'package:drift/drift.dart' as drift;

/// Shows the categories editing bottom sheet.
///
/// Displays a grid of existing categories and an "Add" button.
/// Users can view and manage their expense/income categories.
void showCategoriesSheet(BuildContext context) {
  showAppBottomSheet(
    context: context,
    title: 'Categories',
    mode: SheetMode.auto,
    child: const _CategoriesSheetContent(),
  );
}

class _CategoriesSheetContent extends StatefulWidget {
  const _CategoriesSheetContent();

  @override
  State<_CategoriesSheetContent> createState() =>
      _CategoriesSheetContentState();
}

class _CategoriesSheetContentState extends State<_CategoriesSheetContent> {
  late Future<List<domain.Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesFuture = _getAllCategories();
    });
  }

  Future<List<domain.Category>> _getAllCategories() async {
    final db = AppDatabase();
    final categoryRows = await db.categoriesDao.getAll();

    // Convert database rows to domain categories
    final customCategories = categoryRows.map((row) => row.category).toList();

    // Combine with default categories, filtering out duplicates by id
    final allCategories = [...categories];
    for (final customCategory in customCategories) {
      if (!allCategories.any((cat) => cat.id == customCategory.id)) {
        allCategories.add(customCategory);
      }
    }

    return allCategories;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: FutureBuilder<List<domain.Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading categories: ${snapshot.error}'),
            );
          }

          final displayCategories = snapshot.data ?? categories;

          return Column(
            children: [
              // Categories Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: displayCategories.length + 1, // +1 for add button
                  itemBuilder: (context, index) {
                    // Add button at the end
                    if (index == displayCategories.length) {
                      return GestureDetector(
                        onTap: () async {
                          // Open add category bottom sheet
                          await showAddCategorySheet(context);
                          // Reload categories after adding
                          _loadCategories();
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: DashedBorder(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
                                strokeWidth: 2,
                                dashLength: 8,
                                gapLength: 4,
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 24,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Category item
                    final category = displayCategories[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              category.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Done button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF58CC02),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Shows the add category bottom sheet with input field.
/// Returns a Future that completes when the sheet is closed.
Future<void> showAddCategorySheet(BuildContext context) {
  return showAppBottomSheet(
    context: context,
    title: 'Add Category',
    mode: SheetMode.auto,
    child: _AddCategorySheetContent(),
  );
}

class _AddCategorySheetContent extends StatefulWidget {
  const _AddCategorySheetContent();

  @override
  State<_AddCategorySheetContent> createState() =>
      _AddCategorySheetContentState();
}

class _AddCategorySheetContentState extends State<_AddCategorySheetContent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();
  bool _hasName = false;
  bool _hasEmoji = false;
  Color _selectedColor = Colors.blue; // Default color

  // Predefined colors for selection
  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  // Common emojis for categories
  final List<String> _commonEmojis = [
    '🍔',
    '🚗',
    '🛍️',
    '🎮',
    '💡',
    '💼',
    '✈️',
    '🏠',
    '📱',
    '👕',
    '🍕',
    '☕',
    '🎵',
    '🎬',
    '📚',
    '💊',
    '🏥',
    '🎓',
    '💰',
    '🎁',
    '🏃',
    '⚽',
    '🎨',
    '🛠️',
    '💼',
    '📱',
    '💻',
    '🎧',
    '📷',
    '🎪',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _hasName = _nameController.text.trim().isNotEmpty;
      });
    });
    _emojiController.addListener(() {
      setState(() {
        _hasEmoji = _emojiController.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final incomeColor = const Color(0xFF58CC02);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Name Input
            const Text(
              'Category Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter category name',
                hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.45)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 24),

            // Emoji Selection
            const Text(
              'Emoji',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji Input Field
                TextField(
                  controller: _emojiController,
                  decoration: InputDecoration(
                    hintText: 'Enter emoji or choose from below',
                    hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.45)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: _emojiController.text.isNotEmpty
                        ? Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _selectedColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                _emojiController.text,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                        : null,
                  ),
                  style: const TextStyle(fontSize: 16),
                  maxLength: 2, // Limit to emoji + potential variation selector
                ),

                const SizedBox(height: 12),

                // Common Emojis Grid
                const Text(
                  'Choose from common emojis:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: GridView.builder(
                    scrollDirection: Axis.horizontal,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemCount: _commonEmojis.length,
                    itemBuilder: (context, index) {
                      final emoji = _commonEmojis[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _emojiController.text = emoji;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _emojiController.text == emoji
                                  ? _selectedColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Color Selection
            const Text(
              'Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? cs.onSurface : Colors.transparent,
                          width: isSelected ? 3 : 0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_hasName && _hasEmoji)
                    ? () async {
                        final name = _nameController.text.trim();
                        final emoji = _emojiController.text.trim();

                        // Generate unique ID from name
                        final id = name
                            .toLowerCase()
                            .replaceAll(' ', '_')
                            .replaceAll('&', 'and');

                        // Create new category
                        final newCategory = domain.Category(
                          id: id,
                          name: name,
                          icon: emoji,
                          color: _selectedColor,
                        );

                        // TODO: Save category to database/storage
                        debugPrint(
                          'Adding new category: ${newCategory.toJson()}',
                        );

                        // Save to database
                        final db = AppDatabase();
                        await db.categoriesDao.upsert(
                          CategoriesCompanion(
                            id: drift.Value(id),
                            category: drift.Value(newCategory),
                          ),
                        );

                        debugPrint('✅ Category saved to database');

                        // Close sheet
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.pop(context);

                        // Show success message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Category "$name" added successfully!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_hasName && _hasEmoji)
                      ? incomeColor
                      : Colors.grey[850],
                  foregroundColor: (_hasName && _hasEmoji)
                      ? Colors.white
                      : cs.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(64, 48),
                ),
                child: const Text(
                  'Add Category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper widget for rendering dashed borders around UI elements.
class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const DashedBorder({
    super.key,
    required this.child,
    required this.color,
    this.strokeWidth = 1,
    this.dashLength = 5,
    this.gapLength = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
      ),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    final dashPath = Path();
    double distance = 0.0;
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final start = distance;
        final end = distance + dashLength;
        final bool draw = (distance / (dashLength + gapLength)) % 2 == 0;

        if (draw) {
          dashPath.addPath(
            metric.extractPath(start, end.clamp(0, metric.length)),
            Offset.zero,
          );
        }

        distance = end;
        distance += gapLength;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}
