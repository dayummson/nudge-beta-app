import "package:flutter/material.dart";
import 'dart:ui';
import 'toggle_mode.dart';
import '../../../components/sheet/bottom_sheet_helper.dart';
import '../../../constants/categories.dart';

class Header extends StatelessWidget {
  final double blurSigma;
  final double overlayOpacity;
  final double totalAmount;
  final bool isExpense;
  final void Function(bool) toggleMode;
  // Optional debug overrides (null in normal mode)
  final double? debugBlurOverride;
  final Color? debugOverlayColor;

  const Header({
    super.key,
    required this.blurSigma,
    required this.overlayOpacity,
    required this.totalAmount,
    required this.isExpense,
    required this.toggleMode,
    this.debugBlurOverride,
    this.debugOverlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,

      child: Stack(
        children: [
          // Background layer with blur and fade
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  Colors.black, // Solid at top
                  Colors.black, // Keep solid throughout header content
                  Colors.transparent, // Smooth fade at bottom
                ],
                stops: const [
                  0.0,
                  0.85, // Keep solid until 85% (after toggle mode)
                  1.0, // Smooth fade to transparent
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: debugBlurOverride ?? blurSigma,
                  sigmaY: debugBlurOverride ?? blurSigma,
                ),
                child: Container(
                  color:
                      debugOverlayColor ??
                      colorScheme.surface.withOpacity(overlayOpacity),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),
                          // Top row: title + settings
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(child: SizedBox()),
                              const SizedBox(
                                width: 20,
                                height: 20,
                              ), // Placeholder for alignment
                            ],
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 19), // Placeholder for total
                          const SizedBox(height: 8),
                          const SizedBox(height: 79), // Placeholder for toggle
                          const SizedBox(height: 12), // Bottom padding
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Content layer (not affected by ShaderMask)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Top row: title + settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () => _showSettingsSheet(context),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.settings,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Total in header
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              border: Border.all(
                                color: colorScheme.onSurface.withOpacity(0.2),
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '-',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            totalAmount.toStringAsFixed(2),
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Toggle with fade section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxW = constraints.maxWidth;
                        final toggleW = maxW.isFinite
                            ? (maxW * 0.9).clamp(140.0, 200.0)
                            : 180.0;
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: ToggleMode(
                            isExpense: isExpense,
                            onChanged: (val) => toggleMode(val),
                            width: toggleW,
                            height: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Settings',
      mode: SheetMode.auto,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to notifications
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to theme settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Edit Categories'),
            onTap: () {
              Navigator.pop(context);
              _showEditCategoriesSheet(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showEditCategoriesSheet(BuildContext context) {
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
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
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

            // Save button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save logic
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for dashed border
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
          const Radius.circular(12),
        ),
      );

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    final pathMetrics = path.computeMetrics();

    for (final metric in pathMetrics) {
      double distance = 0;
      bool draw = true;

      while (distance < metric.length) {
        final length = draw ? dashLength : gapLength;
        final end = distance + length;

        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, end.clamp(0, metric.length)),
            Offset.zero,
          );
        }

        distance = end;
        draw = !draw;
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
