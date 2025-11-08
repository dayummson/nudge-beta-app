import 'dart:ui';
import 'package:flutter/material.dart';
import "header.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isExpense = true;

  // Key and measured height for the header so content padding can match the
  // actual header size (makes the header hug its content and avoids hard
  // coding heights that cause overflow).
  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 110.0;

  final List<String> categories = [
    "Food",
    "Transport",
    "Entertainment",
    "Utilities",
    "Health",
  ];
  final List<Map<String, dynamic>> items = [
    {"title": "Groceries", "amount": 50.0},
    {"title": "Bus Ticket", "amount": 2.5},
    {"title": "Movie", "amount": 12.0},
    {"title": "Coffee", "amount": 5.0},
    {"title": "Dinner", "amount": 30.0},
    {"title": "Dinner", "amount": 30.0},
    {"title": "Dinner", "amount": 30.0},
    {"title": "Coffee", "amount": 5.0},
    {"title": "Dinner", "amount": 30.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Movie", "amount": 12.0},
    {"title": "Dinner", "amount": 30.0},
    {"title": "Dinner", "amount": 30.0},
    {"title": "Movie", "amount": 12.0},
  ];

  double get totalAmount => items.fold<double>(
    0.0,
    (sum, e) => sum + (e['amount'] as num).toDouble(),
  );

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void toggleMode(bool isExpense) {
    setState(() {
      isExpense = isExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the measured header height so the header hugs content. Start with
    // a sensible default and update after layout.
    final double headerHeight = _headerHeight;
    // t goes from 0.0 (no scroll) to 1.0 (scrolled past header)
    final double t = headerHeight > 0
        ? (_scrollOffset / headerHeight).clamp(0.0, 1.0)
        : 0.0;
    // Use an eased curve so the fade feels natural
    final double easedT = Curves.easeOut.transform(t);
    // As we scroll, make the header more transparent (lower opacity). Make
    // the minimum very low so the header becomes mostly transparent.
    final double overlayOpacity = lerpDouble(0.7, 0.05, easedT) ?? 0.7;
    // Reduce blur as we scroll so underlying content becomes clearer.
    final double blurSigma = lerpDouble(10.0, 1.0, easedT) ?? 10.0;
    // Theme-aware colors
    final colorScheme = Theme.of(context).colorScheme;
    final miniTextColor = colorScheme.onSurface.withAlpha((0.72 * 255).round());
    // After this frame, measure the header size and update _headerHeight if
    // it changed. We schedule measurement here so it runs after layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final ctx = _headerKey.currentContext;
        if (ctx != null) {
          final h = ctx.size?.height ?? _headerHeight;
          if ((h - _headerHeight).abs() > 1.0) {
            setState(() {
              _headerHeight = h;
            });
          }
        }
      } catch (_) {}
    });

    return Scaffold(
      // Use surface instead of background per new color scheme guidance.
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Scrollable content
          Padding(
            // leave a bit more room above the scrollable content so the
            // categories area has breathing room beneath the header
            padding: EdgeInsets.only(top: headerHeight + 12),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // extra spacing above the categories for visual separation
                  // Horizontal categories
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              categories[index],
                              style: TextStyle(color: colorScheme.onPrimary),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Mini total (tiny text for context while scrolling)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      "Total: \$${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 12, color: miniTextColor),
                    ),
                  ),

                  // Vertical list of items
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item['title']),
                        trailing: Text("\$${item['amount']}"),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Sticky header with blur
          Header(
            key: _headerKey,
            blurSigma: blurSigma,
            overlayOpacity: overlayOpacity,
            isExpense: isExpense,
            totalAmount: totalAmount,
            toggleMode: toggleMode,
          ),
        ],
      ),
    );
  }
}
