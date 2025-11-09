import 'package:flutter/material.dart';

// This is change
/// A two-option sliding toggle for Income (left, green) and Expense (right, red).
///
/// Usage:
/// ToggleMode(isExpense: false, onChanged: (v) => ...)
class ToggleMode extends StatefulWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;

  const ToggleMode({
    super.key,
    required this.isExpense,
    required this.onChanged,
    this.width = 200,
    this.height = 32,
  });

  @override
  State<ToggleMode> createState() => _ToggleModeState();
}

class _ToggleModeState extends State<ToggleMode> {
  late bool _isExpense;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
  }

  @override
  void didUpdateWidget(covariant ToggleMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpense != oldWidget.isExpense) {
      _isExpense = widget.isExpense;
    }
  }

  void _toggle(bool toExpense) {
    if (toExpense == _isExpense) return;
    setState(() => _isExpense = toExpense);
    widget.onChanged(_isExpense);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fun, playful colors
    final incomeColor = isDark
        ? const Color(0xFF58CC02) // Duolingo green for dark mode
        : const Color(0xFF58CC02); // Duolingo green for light mode
    final expenseColor = isDark
        ? const Color(0xFFFF6B6B) // Coral red for dark mode
        : const Color(0xFFEF5350); // Bright red for light mode

    final textColor = isDark ? Colors.white : Colors.black87;

    return Semantics(
      button: true,
      label: 'Toggle Expense (left) or Income (right)',
      child: GestureDetector(
        onTapDown: (_) => _toggle(!_isExpense),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.transparent, // Inherit parent background
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
              // Sliding knob (behind labels)
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: _isExpense
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: widget.height - 10,
                    decoration: BoxDecoration(
                      color: _isExpense ? expenseColor : incomeColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (_isExpense ? expenseColor : incomeColor)
                              .withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Labels (on top)
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        '- P602.50',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isExpense ? Colors.white : textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '+ P12.00',
                        style: TextStyle(
                          fontSize: 12,
                          color: !_isExpense ? Colors.white : textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
