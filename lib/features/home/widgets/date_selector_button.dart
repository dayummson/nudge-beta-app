import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nudge_1/components/sheet/bottom_sheet_helper.dart';

class DateSelectorButton extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelectorButton({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  String _getDateDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    final difference = selected.difference(today).inDays;
    if (difference == -1) return 'Yesterday';
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    return DateFormat('MMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: () => _showDateSheet(context),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: const StadiumBorder(),
        side: BorderSide(color: cs.onSurface.withOpacity(0.2)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getDateDisplay(selectedDate),
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.calendar_today,
            size: 16,
            color: cs.onSurface.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  void _showDateSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: null,
      mode: SheetMode.auto,
      child: _DateSheetContent(
        initialDate: selectedDate,
        onDateSelected: onDateSelected,
      ),
    );
  }
}

class _DateSheetContent extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const _DateSheetContent({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_DateSheetContent> createState() => _DateSheetContentState();
}

class _DateSheetContentState extends State<_DateSheetContent> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with Date and Close button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: cs.onSurface.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: cs.onSurface),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
        // Date Picker
        SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
                widget.onDateSelected(date);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
