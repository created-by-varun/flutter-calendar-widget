import 'package:flutter/material.dart';
import '../utils/date_utils.dart';

/// Widget that represents a single day in the calendar
class CalendarDay extends StatelessWidget {
  /// The date this day represents
  final DateTime date;

  /// The currently selected date
  final DateTime? selectedDate;

  /// Minimum selectable date
  final DateTime? minDate;

  /// Maximum selectable date
  final DateTime? maxDate;

  /// Whether this day is in the current month
  final bool isInCurrentMonth;

  /// Callback when the day is tapped
  final ValueChanged<DateTime>? onDateSelected;

  /// Whether this day is disabled
  final bool isDisabled;

  /// Creates a calendar day widget
  const CalendarDay({
    Key? key,
    required this.date,
    this.selectedDate,
    this.minDate,
    this.maxDate,
    required this.isInCurrentMonth,
    this.onDateSelected,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedDate != null && CalendarDateUtils.isSameDay(date, selectedDate!);
    final isToday = CalendarDateUtils.isSameDay(date, DateTime.now());
    final theme = Theme.of(context);
    
    // Don't show days from other months
    if (!isInCurrentMonth) {
      return const SizedBox();
    }

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : () => onDateSelected?.call(date),
            borderRadius: BorderRadius.circular(50),
            splashColor: theme.colorScheme.primary.withOpacity(0.3),
            highlightColor: theme.colorScheme.primary.withOpacity(0.1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                border: isToday && !isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                    : null,
                boxShadow: isSelected
                    ? [BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : (isDisabled
                            ? theme.colorScheme.onSurface.withOpacity(0.4)
                            : (isToday && !isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
