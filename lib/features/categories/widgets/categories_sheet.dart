import 'package:flutter/material.dart';
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';
import 'package:nudge_1/constants/categories.dart';

/// Shows the categories editing bottom sheet.
///
/// Displays a grid of existing categories and an "Add" button.
/// Users can view and manage their expense/income categories.
void showCategoriesSheet(BuildContext context) {
  showAppBottomSheet(
    context: context,
    title: 'Categories',
    mode: SheetMode.auto,
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
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
              itemCount: categories.length + 1, // +1 for add button
              itemBuilder: (context, index) {
                // Add button at the end
                if (index == categories.length) {
                  return GestureDetector(
                    onTap: () {
                      // Open add category bottom sheet
                      showAddCategorySheet(context);
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
                final category = categories[index];
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
        ],
      ),
    ),
  );
}

/// Shows the add category bottom sheet with input field.
void showAddCategorySheet(BuildContext context) {
  showAppBottomSheet(
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
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final incomeColor = const Color(0xFF58CC02);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Category name',
                  hintStyle: TextStyle(
                    color: cs.onSurface.withOpacity(0.45),
                    fontSize: 28,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _hasText
                      ? () async {
                          final trimmed = _controller.text.trim();
                          // TODO: Implement add category logic
                          print('Add category: $trimmed');
                          Navigator.pop(context);
                        }
                      : null,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Save'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasText ? incomeColor : Colors.grey[850],
                    foregroundColor: _hasText ? Colors.white : cs.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 14,
                    ),
                    minimumSize: const Size(64, 48),
                  ),
                ),
              ),
            ],
          ),
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
