import 'package:flutter/material.dart';

class AmountInputSection extends StatelessWidget {
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final FocusNode inlineAmountFocusNode;
  final bool isExpense;
  final Function(bool) onExpenseChanged;

  const AmountInputSection({
    super.key,
    required this.descriptionController,
    required this.amountController,
    required this.inlineAmountFocusNode,
    required this.isExpense,
    required this.onExpenseChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = cs.onSurface.withOpacity(0.5);
    final incomeColor = const Color(0xFF58CC02);
    final expenseColor = isDark
        ? const Color(0xFFFF6B6B)
        : const Color(0xFFEF5350);

    Widget field(TextEditingController c, String hint, {TextInputType? type}) =>
        TextField(
          controller: c,
          keyboardType: type,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: 0.2,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: hintColor,
              fontSize: 24,
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
      final activeColor = isExpense ? expenseColor : incomeColor;
      return GestureDetector(
        onTapDown: (d) {
          final toExpense = d.localPosition.dx < (w / 2);
          if (toExpense != isExpense) {
            onExpenseChanged(toExpense);
          }
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
                alignment: isExpense
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: field(descriptionController, 'Description'),
        ),
        const SizedBox(height: 2),
        // Show top amount input only when there's no amount typed yet.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: amountController,
          builder: (context, val, _) {
            final empty = val.text.trim().isEmpty;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: empty
                  ? Padding(
                      key: const ValueKey('topAmountField'),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: field(
                        amountController,
                        'Amount',
                        type: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    )
                  : const SizedBox(key: ValueKey('topAmountHidden')),
            );
          },
        ),
        const SizedBox(height: 6),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: amountController,
          builder: (context, value, _) {
            final show = value.text.trim().isNotEmpty;
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
                    child: FadeTransition(opacity: animation, child: child),
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
                          // Inline editable amount field that takes focus when shown
                          Expanded(
                            child: Builder(
                              builder: (ctx) {
                                // Request focus when the inline field appears
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!inlineAmountFocusNode.hasFocus) {
                                    amountController
                                        .selection = TextSelection.fromPosition(
                                      TextPosition(
                                        offset: amountController.text.length,
                                      ),
                                    );
                                    inlineAmountFocusNode.requestFocus();
                                  }
                                });

                                return TextField(
                                  controller: amountController,
                                  focusNode: inlineAmountFocusNode,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: isExpense
                                        ? expenseColor
                                        : incomeColor,
                                    height: 1,
                                  ),
                                  decoration: InputDecoration(
                                    prefixText: '₱ ',
                                    prefixStyle: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: isExpense
                                          ? expenseColor
                                          : incomeColor,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(key: ValueKey('emptyRow')),
            );
          },
        ),
      ],
    );
  }
}
