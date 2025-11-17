import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/providers/search_enabled_provider.dart';
import '../presentation/pages/voice_page.dart';
import '../../../components/sheet/bottom_sheet_helper.dart';
import '../../../constants/categories.dart' as constants;

class FloatingActionButtons extends ConsumerStatefulWidget {
  const FloatingActionButtons({super.key});

  @override
  ConsumerState<FloatingActionButtons> createState() =>
      _FloatingActionButtonsState();
}

class _FloatingActionButtonsState extends ConsumerState<FloatingActionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _searchController.clear();
    ref.read(searchEnabledProvider.notifier).setEnabled(false);
  }

  void _showAddTransactionSheet(BuildContext context) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedCategoryId;
    bool isExpense = true; // local toggle state

    showAppBottomSheet(
      context: context,
      title: null,
      heightFactor: 0.6,
      contentPadding: const EdgeInsets.only(top: 12),
      child: StatefulBuilder(
        builder: (context, setModalState) {
          final cs = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final hintColor = cs.onSurface.withOpacity(0.5);
          final Color borderColor = isDark
              ? Colors.grey.shade700
              : Colors.grey.shade400;
          final incomeColor = const Color(0xFF58CC02);
          final expenseColor = isDark
              ? const Color(0xFFFF6B6B)
              : const Color(0xFFEF5350);

          Widget buildBorderlessField({
            required TextEditingController controller,
            required String hint,
            TextInputType? keyboardType,
          }) {
            return TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: hintColor),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            );
          }

          Widget buildToggle() {
            const double toggleWidth = 88;
            const double toggleHeight = 36;
            final activeColor = isExpense ? expenseColor : incomeColor;
            return GestureDetector(
              onTapDown: (details) {
                final dx = details.localPosition.dx;
                final toExpense = dx < (toggleWidth / 2);
                if (toExpense != isExpense) {
                  setModalState(() => isExpense = toExpense);
                }
              },
              child: Container(
                width: toggleWidth,
                height: toggleHeight,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      alignment: isExpense
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          height: toggleHeight - 10,
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              '-',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isExpense
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: !isExpense
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          Widget buildAmountPreview(String text) {
            final amountColor = isExpense ? expenseColor : incomeColor;
            return Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                  height: 1.0,
                ),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: buildBorderlessField(
                  controller: descriptionController,
                  hint: 'Description',
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: buildBorderlessField(
                  controller: amountController,
                  hint: 'Amount',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              ValueListenableBuilder<TextEditingValue>(
                valueListenable: amountController,
                builder: (context, value, _) {
                  final show = value.text.trim().isNotEmpty;
                  final raw = value.text.trim();
                  final parsed = double.tryParse(raw);
                  final display = parsed != null
                      ? parsed.toStringAsFixed(2)
                      : '0.00';
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slide =
                          Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          );
                      return ClipRect(
                        child: SlideTransition(
                          position: slide,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: show
                        ? Padding(
                            key: const ValueKey('amountRow'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Row(
                              children: [
                                buildToggle(),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: buildAmountPreview('₱ $display'),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(key: ValueKey('emptyRow')),
                  );
                },
              ),
              const SizedBox(height: 16),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {
                        // TODO: add category action
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: const StadiumBorder(),
                        side: BorderSide(color: borderColor),
                        backgroundColor: cs.surfaceVariant,
                        foregroundColor: cs.onSurfaceVariant,
                      ),
                      child: const Icon(Icons.add, size: 18),
                    ),
                    const SizedBox(width: 8),
                    ...() {
                      final chips = <Widget>[];
                      for (int i = 0; i < constants.categories.length; i++) {
                        final cat = constants.categories[i];
                        final selected = cat.id == selectedCategoryId;
                        if (i > 0) chips.add(const SizedBox(width: 8));
                        chips.add(
                          ChoiceChip(
                            selected: selected,
                            onSelected: (val) {
                              setModalState(
                                () => selectedCategoryId = val ? cat.id : null,
                              );
                            },
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cat.icon,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(cat.name),
                              ],
                            ),
                            shape: const StadiumBorder(),
                            side: BorderSide(color: borderColor),
                            backgroundColor: cs.surfaceVariant.withOpacity(0.6),
                            selectedColor: cs.primaryContainer,
                            labelStyle: TextStyle(
                              color: selected
                                  ? cs.onPrimaryContainer
                                  : cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }
                      return chips;
                    }(),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // TODO: hashtag action
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: cs.surfaceVariant,
                        side: BorderSide(color: borderColor),
                        foregroundColor: cs.onSurfaceVariant,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Icon(Icons.tag, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: save logic
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check, size: 18),
                            SizedBox(width: 8),
                            Text('Save'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searchEnabled = ref.watch(searchEnabledProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.02; // 2% of screen width

    if (searchEnabled) {
      _animationController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    } else {
      _animationController.reverse();
    }

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: searchEnabled ? horizontalPadding : -400, // Slide in from left
          right: horizontalPadding,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey[800]!, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Icon(Icons.search, color: colorScheme.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search transactions...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) {
                            // TODO: Implement search logic
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _closeSearch,
                        icon: Icon(Icons.close, color: colorScheme.onSurface),
                        padding: const EdgeInsets.all(8),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: searchEnabled ? -200 : horizontalPadding, // Slide out to left
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FadeTransition(
                opacity: ReverseAnimation(_fadeAnimation),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(
                      color: colorScheme.onSurface.withOpacity(0.2),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => _showAddTransactionSheet(context),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.add,
                              color: colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            ref.read(searchEnabledProvider.notifier).toggle();
                          },
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.search,
                              color: colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          right: searchEnabled
              ? -100
              : horizontalPadding, // Hide when search active
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FadeTransition(
                opacity: ReverseAnimation(_fadeAnimation),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const VoicePage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                        transitionDuration: const Duration(milliseconds: 200),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFFEF5350),
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.mic, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
