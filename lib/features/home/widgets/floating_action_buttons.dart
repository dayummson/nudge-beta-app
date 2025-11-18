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

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isExpense = true;
  String? _selectedCategoryId;

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
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _toggleSearch() => ref.read(searchEnabledProvider.notifier).toggle();

  Future<void> _showAddTransactionSheet() async {
    await showAppBottomSheet(
      context: context,
      mode: SheetMode.auto,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          final cs = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final hintColor = cs.onSurface.withOpacity(0.5);
          final borderColor = isDark
              ? Colors.grey.shade700
              : Colors.grey.shade400;
          final incomeColor = const Color(0xFF58CC02);
          final expenseColor = isDark
              ? const Color(0xFFFF6B6B)
              : const Color(0xFFEF5350);

          Widget field(
            TextEditingController c,
            String hint, {
            TextInputType? type,
          }) => TextField(
            controller: c,
            keyboardType: type,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700, // bolder text
              height: 1.2,
              letterSpacing: 0.2,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: hintColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          );

          Widget toggle() {
            const w = 88.0;
            const h = 36.0;
            final activeColor = _isExpense ? expenseColor : incomeColor;
            return GestureDetector(
              onTapDown: (d) {
                final toExpense = d.localPosition.dx < (w / 2);
                if (toExpense != _isExpense)
                  setModalState(() => _isExpense = toExpense);
              },
              child: Container(
                width: w,
                height: h,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white24 : Colors.black12,
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      alignment: _isExpense
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          height: h - 10,
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
                                color: _isExpense
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
                                color: !_isExpense
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

          Widget amountPreview(String text) => Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              '₱ $text',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _isExpense ? expenseColor : incomeColor,
                height: 1,
              ),
            ),
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: field(_descriptionController, 'Description'),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: field(
                  _amountController,
                  'Amount',
                  type: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _amountController,
                builder: (context, value, _) {
                  final show = value.text.trim().isNotEmpty;
                  final parsed = double.tryParse(value.text.trim());
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                toggle(),
                                const SizedBox(width: 12),
                                Expanded(child: amountPreview(display)),
                              ],
                            ),
                          )
                        : const SizedBox(key: ValueKey('emptyRow')),
                  );
                },
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final isCollapsed =
                      child.key == const ValueKey('chipsCollapsed');
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
                child: _selectedCategoryId == null
                    ? SingleChildScrollView(
                        key: const ValueKey('chipsFull'),
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () {},
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
                            ...constants.categories.map((cat) {
                              final selected = cat.id == _selectedCategoryId;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  selected: selected,
                                  onSelected: (val) => setModalState(
                                    () => _selectedCategoryId = val
                                        ? cat.id
                                        : null,
                                  ),
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
                                  backgroundColor: cs.surfaceVariant
                                      .withOpacity(0.6),
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
                            }).toList(),
                            const SizedBox(width: 16),
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
                              onSelected: (_) => setModalState(
                                () => _selectedCategoryId = null,
                              ),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    constants.categories
                                        .firstWhere(
                                          (c) => c.id == _selectedCategoryId,
                                        )
                                        .icon,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    constants.categories
                                        .firstWhere(
                                          (c) => c.id == _selectedCategoryId,
                                        )
                                        .name,
                                  ),
                                ],
                              ),
                              shape: const StadiumBorder(),
                              side: BorderSide(color: borderColor),
                              backgroundColor: cs.primaryContainer,
                              selectedColor: cs.primaryContainer,
                              labelStyle: TextStyle(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _selectedCategoryId == null
                    ? Padding(
                        key: const ValueKey('actionsFull'),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: cs.surfaceVariant,
                                side: BorderSide(color: borderColor),
                                foregroundColor: cs.onSurfaceVariant,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('#'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: const StadiumBorder(),
                                  backgroundColor: cs.primary,
                                  foregroundColor: cs.onPrimary,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        key: const ValueKey('actionsCollapsed'),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: const StadiumBorder(),
                                  backgroundColor: cs.primary,
                                  foregroundColor: cs.onPrimary,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
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
    final horizontalPadding = screenWidth * 0.02;

    if (searchEnabled) {
      _animationController.forward();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _searchFocusNode.requestFocus(),
      );
    } else {
      _animationController.reverse();
    }

    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          left: searchEnabled ? horizontalPadding : -400,
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
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search transactions...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleSearch,
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
          left: searchEnabled ? -200 : horizontalPadding,
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
                          onTap: _showAddTransactionSheet,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.add, size: 20),
                          ),
                        ),
                        InkWell(
                          onTap: _toggleSearch,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.search, size: 20),
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
          right: searchEnabled ? -100 : horizontalPadding,
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
                            (context, animation, secondaryAnimation, child) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
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
