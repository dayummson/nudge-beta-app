import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../../widgets/header.dart";
import "../../widgets/floating_action_buttons.dart";
import "../../widgets/categories_list.dart";
import "../../widgets/transactions_list.dart";
import "../../data/mock_expenses.dart";
import "../../../room/domain/entities/expense.dart";

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool isExpense = true;

  // Key and measured height for the header so content padding can match the
  // actual header size (makes the header hug its content and avoids hard
  // coding heights that cause overflow).
  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 110.0;
  // Debug mode: 0 = normal, 1 = force-high-blur, 2 = visible-scrim (debug color)
  int _debugMode = 0;

  // Mock expense data
  final List<Expense> expenses = mockExpenses;

  double get totalAmount =>
      expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

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
      this.isExpense = isExpense;
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
    // Header background opacity increases as content scrolls under it
    // Start more opaque for better content visibility
    final double overlayOpacity = lerpDouble(0.95, 0.98, easedT) ?? 0.95;
    // Blur - keep it minimal to avoid blue tint on content
    final double blurSigma = lerpDouble(0.0, 2.0, easedT) ?? 0.0;
    // Content fade: after reaching 100% scroll, content beneath header starts fading
    // Start fading at 95% scroll, completely invisible by 120% scroll
    final double contentFadeT = (t - 0.95).clamp(0.0, 0.25) / 0.25;
    final double contentOpacity =
        lerpDouble(1.0, 0.0, Curves.easeIn.transform(contentFadeT)) ?? 1.0;
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Stack(
          children: [
            Stack(
              children: [
                // Scrollable content - starts at top of screen so it can scroll under the header
                // Wrapped with Opacity for content fade effect
                Opacity(
                  opacity: contentOpacity,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add top spacing equal to header height so first item isn't hidden
                        SizedBox(height: headerHeight),
                        // Horizontal categories
                        const CategoriesList(),

                        // Transactions list with mini total
                        TransactionsList(
                          expenses: expenses,
                          miniTextColor: miniTextColor,
                          totalAmount: totalAmount,
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
                  // debug overrides
                  debugBlurOverride: _debugMode == 1 ? 20.0 : null,
                  debugOverlayColor: _debugMode == 2
                      ? Colors.purple.withOpacity(0.16)
                      : null,
                ),
              ],
            ),
            // Floating action buttons with search transition
            const FloatingActionButtons(),
          ],
        ),
      ),
    );
  }
}
