import 'package:flutter/material.dart';
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';

/// Shows the month selection bottom sheet.
///
/// Allows users to filter transactions by:
/// - All time
/// - Specific year
/// - Individual months
void showMonthSheet(
  BuildContext context, {
  required String currentDisplayText,
  required bool isExpense,
  required Map<int, double>? monthTotals,
  required Function(String, int?, int?) onApply,
}) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final year = DateTime.now().year.toString();
  final currentMonth = DateTime.now().month - 1; // 0-indexed
  final months = const [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  final monthsFull = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  showAppBottomSheet(
    context: context,
    title: null,
    mode: SheetMode.auto,
    child: _MonthSheetContent(
      cs: cs,
      isDark: isDark,
      year: year,
      currentMonth: currentMonth,
      months: months,
      monthsFull: monthsFull,
      currentDisplayText: currentDisplayText,
      monthTotals: monthTotals,
      onApply: onApply,
    ),
  );
}

class _MonthSheetContent extends StatefulWidget {
  final ColorScheme cs;
  final bool isDark;
  final String year;
  final int currentMonth;
  final List<String> months;
  final List<String> monthsFull;
  final String currentDisplayText;
  final Map<int, double>? monthTotals;
  final Function(String, int?, int?) onApply;

  const _MonthSheetContent({
    required this.cs,
    required this.isDark,
    required this.year,
    required this.currentMonth,
    required this.months,
    required this.monthsFull,
    required this.currentDisplayText,
    required this.monthTotals,
    required this.onApply,
  });

  @override
  State<_MonthSheetContent> createState() => _MonthSheetContentState();
}

class _MonthSheetContentState extends State<_MonthSheetContent> {
  late int selectedMode;
  int? selectedMonthIndex;

  @override
  void initState() {
    super.initState();
    // Determine initial mode and selected month
    selectedMode = widget.currentDisplayText == 'All time' ? 0 : 1;

    // If current text is a month name, find its index
    if (widget.currentDisplayText != 'All time') {
      selectedMonthIndex = widget.monthsFull.indexOf(widget.currentDisplayText);
      if (selectedMonthIndex == -1) {
        selectedMonthIndex = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseColor = widget.isDark
        ? const Color(0xFFFF6B6B)
        : const Color(0xFFEF5350);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: widget.cs.onSurface),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Month',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: widget.cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() {
                    selectedMode = 0;
                    selectedMonthIndex = null;
                  }),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    shape: const StadiumBorder(),
                    backgroundColor: selectedMode == 0
                        ? widget.cs.primaryContainer
                        : Colors.transparent,
                    foregroundColor: selectedMode == 0
                        ? widget.cs.onPrimaryContainer
                        : widget.cs.onSurface,
                    side: BorderSide.none,
                  ),
                  child: const Text('All time'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => setState(() {
                    selectedMode = 1;
                    if (selectedMonthIndex == null) {
                      selectedMonthIndex = widget.currentMonth;
                    }
                  }),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    shape: const StadiumBorder(),
                    backgroundColor: selectedMode == 1
                        ? widget.cs.primaryContainer
                        : Colors.transparent,
                    foregroundColor: selectedMode == 1
                        ? widget.cs.onPrimaryContainer
                        : widget.cs.onSurface,
                    side: BorderSide.none,
                  ),
                  child: Text(widget.year),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.grey[850]
                    : widget.cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                ),
                itemCount: widget.months.length,
                itemBuilder: (context, index) {
                  final isSelected =
                      selectedMonthIndex == index && selectedMode == 1;
                  // Get actual total from database
                  final total = widget.monthTotals?[index + 1] ?? 0.0;
                  final hasValue = total > 0;
                  final isCurrentMonth = index == widget.currentMonth;

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: expenseColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedMonthIndex = index;
                          selectedMode = 1;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: isCurrentMonth
                            ? (isSelected
                                  ? expenseColor
                                  : expenseColor.withOpacity(0.3))
                            : (isSelected ? expenseColor : Colors.transparent),
                        foregroundColor: isSelected
                            ? Colors.white
                            : widget.cs.onSurfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.months[index],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (hasValue) ...[
                            const SizedBox(height: 4),
                            Text(
                              '₱${total.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : widget.cs.onSurfaceVariant.withOpacity(
                                        0.7,
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  String displayText;
                  int? month;
                  int? year;

                  if (selectedMode == 0) {
                    displayText = 'All time';
                    month = null;
                    year = null;
                  } else if (selectedMonthIndex != null) {
                    displayText = widget.monthsFull[selectedMonthIndex!];
                    month = selectedMonthIndex! + 1; // Convert to 1-12
                    year = int.parse(widget.year);
                  } else {
                    displayText = widget.monthsFull[widget.currentMonth];
                    month = widget.currentMonth + 1; // Convert to 1-12
                    year = int.parse(widget.year);
                  }

                  widget.onApply(displayText, month, year);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  backgroundColor: widget.cs.primary,
                  foregroundColor: widget.cs.onPrimary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(64, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Apply'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
