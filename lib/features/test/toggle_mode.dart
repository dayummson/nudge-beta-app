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
    this.width = 160,
    this.height = 34,
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
    final surface = theme.colorScheme.surface;
    // Use scheme-aware colors so the toggle adapts to light/dark themes.
    final incomeColor = theme.colorScheme.primary;
    final expenseColor = theme.colorScheme.error;

    return Semantics(
      button: true,
      label: 'Toggle Expense (left) or Income (right)',
      child: GestureDetector(
        onTapDown: (_) => _toggle(!_isExpense),
        child: Container(
          width: widget.width,
          height: widget.height,
          // slightly smaller internal padding to reduce overall footprint
          padding: const EdgeInsets.symmetric(horizontal: 0.2, vertical: 2.5),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(widget.height / 2),
            // subtle outline so the toggle reads on both light/dark themes
            border: Border.all(color: theme.colorScheme.outline, width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Labels
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _toggle(true),
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      child: Center(
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isExpense
                                ? theme.colorScheme.onSurface.withAlpha(0)
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: InkWell(
                      onTap: () => _toggle(false),
                      borderRadius: BorderRadius.circular(widget.height / 2),
                      child: Center(
                        child: Text(
                          'Income',
                          style: TextStyle(
                            fontSize: 12,
                            color: !_isExpense
                                ? theme.colorScheme.onSurface.withAlpha(0)
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Sliding knob
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: _isExpense
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    // adapt knob sizing for the reduced padding
                    width: (widget.width - 6) / 2,
                    height: widget.height - 6,
                    decoration: BoxDecoration(
                      color: _isExpense ? expenseColor : incomeColor,
                      borderRadius: BorderRadius.circular(
                        (widget.height - 6) / 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.12 * 255).round()),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _isExpense ? 'Expense' : 'Income',
                        style: TextStyle(
                          color: _isExpense
                              ? theme.colorScheme.onError
                              : theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
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
