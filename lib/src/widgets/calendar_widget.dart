import 'package:flutter/material.dart';
import '../models/day.dart';
import '../utils/date_utils.dart';
import 'calendar_day.dart';

/// A customizable calendar widget
class CalendarWidget extends StatefulWidget {
  /// The currently selected date
  final DateTime? selectedDate;

  /// Minimum selectable date
  final DateTime? minDate;

  /// Maximum selectable date
  final DateTime? maxDate;

  /// Days of week that should be disabled
  final List<Day>? disabledDays;

  /// Callback when a date is selected
  final ValueChanged<DateTime>? onChange;

  /// Creates a calendar widget
  const CalendarWidget({
    Key? key,
    this.selectedDate,
    this.minDate,
    this.maxDate,
    this.disabledDays,
    this.onChange,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget>
    with TickerProviderStateMixin {
  late DateTime _currentMonth;
  late List<Day> _weekdays;
  bool _isMonthYearSelectorVisible = false;
  bool _isYearSelectionMode = true; // Start with year selection

  // To track last selected date for animations
  DateTime? _lastSelectedDate;

  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isForward = true; // Direction of slide animation

  // Selected date label animation controller
  late AnimationController _dateAnimController;
  late Animation<Offset> _dateSlideAnimation;

  // List of years to display in the year selector
  List<int> _yearsList = [];

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedDate ?? DateTime.now();
    _lastSelectedDate = widget.selectedDate; // Track initial selected date
    _weekdays = [
      Day.sunday,
      Day.monday,
      Day.tuesday,
      Day.wednesday,
      Day.thursday,
      Day.friday,
      Day.saturday,
    ];

    // Initialize month navigation animation controller
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize month slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    // Initialize date label animation controller
    _dateAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Initialize date label slide animation (slide up)
    _dateSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Start from below
      end: Offset.zero, // End at original position
    ).animate(
      CurvedAnimation(parent: _dateAnimController, curve: Curves.easeOutCubic),
    );

    // Initialize the years list
    _initYearsList();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _dateAnimController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Detect if selected date has changed
    if (widget.selectedDate != oldWidget.selectedDate &&
        widget.selectedDate != null) {
      // Only animate if we have both a previous and new date (not initial selection)
      if (_lastSelectedDate != null) {
        // Reset and play the slide-up animation
        _dateAnimController.reset();
        _dateAnimController.forward();
      }

      // Update the last selected date for next comparison
      _lastSelectedDate = widget.selectedDate;
    }
  }

  void _previousMonth() {
    // Set direction for right-to-left slide (previous month enters from left)
    _isForward = false;

    // Configure animation for sliding right
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Slide in from left
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Reset and start animation
    _slideController.reset();
    _slideController.forward();

    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    // Set direction for left-to-right slide (next month enters from right)
    _isForward = true;

    // Configure animation for sliding left
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Slide in from right
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Reset and start animation
    _slideController.reset();
    _slideController.forward();

    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  bool _isDateDisabled(DateTime date) {
    // Check if date is within min/max range
    if (widget.minDate != null &&
        CalendarDateUtils.isBeforeDay(date, widget.minDate!)) {
      return true;
    }
    if (widget.maxDate != null &&
        CalendarDateUtils.isAfterDay(date, widget.maxDate!)) {
      return true;
    }

    // Check if day of week is disabled
    return CalendarDateUtils.hasDisabledDayOfWeek(date, widget.disabledDays);
  }

  /// Checks if a month has any valid dates that can be selected
  /// Returns true if all dates in the month are disabled
  bool _isMonthDisabled(int year, int month) {
    // If no constraints, month is not disabled
    if (widget.minDate == null &&
        widget.maxDate == null &&
        (widget.disabledDays == null || widget.disabledDays!.isEmpty)) {
      return false;
    }

    // Check if month is entirely before minDate
    if (widget.minDate != null) {
      if (year < widget.minDate!.year ||
          (year == widget.minDate!.year && month < widget.minDate!.month)) {
        return true;
      }
    }

    // Check if month is entirely after maxDate
    if (widget.maxDate != null) {
      if (year > widget.maxDate!.year ||
          (year == widget.maxDate!.year && month > widget.maxDate!.month)) {
        return true;
      }
    }

    // If all days of the week are disabled, month is disabled
    if (widget.disabledDays != null && widget.disabledDays!.length == 7) {
      return true;
    }

    // Check if there's at least one selectable day in the month
    final lastDay = DateTime(year, month + 1, 0); // Last day of month

    // If we have disabled days of week, check if any day in the month is selectable
    if (widget.disabledDays != null && widget.disabledDays!.isNotEmpty) {
      for (int day = 1; day <= lastDay.day; day++) {
        final date = DateTime(year, month, day);
        if (!_isDateDisabled(date)) {
          return false; // Found at least one selectable day
        }
      }
      return true; // All days are disabled
    }

    return false; // Default: month is not disabled
  }

  void _setMonth(int month) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, month, 1);
      _isMonthYearSelectorVisible = false;
      _isYearSelectionMode = true; // Reset for next time
    });
  }

  void _setYear(int year) {
    setState(() {
      _currentMonth = DateTime(year, _currentMonth.month, 1);
      _isYearSelectionMode =
          false; // Move to month selection after year is selected
    });
  }

  void _toggleMonthYearSelector() {
    setState(() {
      _isMonthYearSelectorVisible = !_isMonthYearSelectorVisible;
      if (_isMonthYearSelectorVisible) {
        _isYearSelectionMode = true; // Always start with year selection
        _initYearsList(); // Refresh the years list
      }
    });
  }

  void _initYearsList() {
    // Calculate a range of years to show (16 years total - 4 rows of 4)
    final currentYear = _currentMonth.year;
    // Show the current year in the visible range
    _yearsList = List.generate(16, (index) => currentYear - 7 + index);
  }

  void _showEarlierYears() {
    setState(() {
      // Show 16 earlier years (exactly 4 rows of 4)
      _yearsList = List.generate(16, (index) => _yearsList.first - 16 + index);
    });
  }

  void _showLaterYears() {
    setState(() {
      // Show the next 16 years (exactly 4 rows of 4)
      _yearsList = List.generate(16, (index) => _yearsList.last + 1 + index);
    });
  }

  // Helper method to create animated navigation buttons
  Widget _buildNavButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String tooltip,
    required ThemeData theme,
  }) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: Icon(icon, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
        splashColor: theme.colorScheme.primary.withOpacity(0.2),
        highlightColor: theme.colorScheme.primary.withOpacity(0.1),
        hoverColor: theme.colorScheme.primary.withOpacity(0.05),
      ),
    );
  }

  Widget _buildMonthYearSelector(ThemeData theme) {
    final months = [
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title and close button
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            child: Row(
              children: [
                if (!_isYearSelectionMode)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _isYearSelectionMode = true;
                      });
                    },
                  ),
                Expanded(
                  child: Text(
                    _isYearSelectionMode ? 'Select Year' : 'Select Month',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isMonthYearSelectorVisible = false;
                      _isYearSelectionMode = true; // Reset for next time
                    });
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Year selection
          if (_isYearSelectionMode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Year navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _showEarlierYears,
                        tooltip: 'Previous Years',
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _showLaterYears,
                        tooltip: 'Next Years',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Year grid - non-scrollable, fixed 12 years
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: List.generate(_yearsList.length, (index) {
                      final year = _yearsList[index];
                      final isSelected = _currentMonth.year == year;

                      // Check if the year is outside min/max constraints
                      bool isDisabled = false;
                      if (widget.minDate != null &&
                          year < widget.minDate!.year) {
                        isDisabled = true;
                      }
                      if (widget.maxDate != null &&
                          year > widget.maxDate!.year) {
                        isDisabled = true;
                      }

                      return InkWell(
                        onTap: isDisabled ? null : () => _setYear(year),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : (isDisabled
                                        ? theme.colorScheme.surfaceVariant
                                            .withOpacity(0.5)
                                        : theme.colorScheme.surfaceVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$year',
                            style: TextStyle(
                              color:
                                  isDisabled
                                      ? theme.colorScheme.onSurfaceVariant
                                          .withOpacity(0.5)
                                      : (isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurfaceVariant),
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

          // Month selection
          if (!_isYearSelectionMode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    _currentMonth.year.toString(),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      final isSelected = _currentMonth.month == month;
                      // Check if month has any valid selectable dates
                      final bool isDisabled = _isMonthDisabled(
                        _currentMonth.year,
                        month,
                      );
                      return InkWell(
                        onTap: isDisabled ? null : () => _setMonth(month),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : (isDisabled
                                        ? theme.colorScheme.surfaceVariant
                                            .withOpacity(0.5)
                                        : theme.colorScheme.surfaceVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            months[index],
                            style: TextStyle(
                              color:
                                  isDisabled
                                      ? theme.colorScheme.onSurfaceVariant
                                          .withOpacity(0.5)
                                      : (isSelected
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurfaceVariant),
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If month/year selector is visible, show only that UI and hide the calendar
    if (_isMonthYearSelectorVisible) {
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: _buildMonthYearSelector(theme),
      );
    }

    // Get the first day of month
    final firstDayOfMonth = CalendarDateUtils.getFirstDayOfMonth(_currentMonth);
    // Get the day of week (0-6, Sunday-Saturday)
    final firstWeekdayOfMonth = CalendarDateUtils.getDayOfWeek(firstDayOfMonth);
    // Get the number of days in the month
    final daysInMonth = CalendarDateUtils.getLastDayOfMonth(_currentMonth).day;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected date header with slide-up animation
          if (widget.selectedDate != null)
            AnimatedOpacity(
              opacity: _isMonthYearSelectorVisible ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Date with slide-up animation
                    SlideTransition(
                      position: _dateSlideAnimation,
                      child: Text(
                        CalendarDateUtils.formatDayMonth(widget.selectedDate!),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Month selector with animation
          AnimatedOpacity(
            opacity: _isMonthYearSelectorVisible ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isMonthYearSelectorVisible ? 0 : null,
              child:
                  _isMonthYearSelectorVisible
                      ? const SizedBox()
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Month and year dropdown with ripple effect
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: _toggleMonthYearSelector,
                              borderRadius: BorderRadius.circular(8),
                              splashColor: colorScheme.primary.withOpacity(0.1),
                              highlightColor: colorScheme.primary.withOpacity(
                                0.05,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      CalendarDateUtils.formatMonthYear(
                                        _currentMonth,
                                      ),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Navigation arrows with animated effect
                          Row(
                            children: [
                              _buildNavButton(
                                onPressed: _previousMonth,
                                icon: Icons.chevron_left,
                                tooltip: 'Previous Month',
                                theme: theme,
                              ),
                              const SizedBox(width: 4),
                              _buildNavButton(
                                onPressed: _nextMonth,
                                icon: Icons.chevron_right,
                                tooltip: 'Next Month',
                                theme: theme,
                              ),
                            ],
                          ),
                        ],
                      ),
            ),
          ),

          // Month and Year Selector with animation
          AnimatedCrossFade(
            firstChild: _buildMonthYearSelector(theme),
            secondChild: const SizedBox(height: 0),
            crossFadeState:
                _isMonthYearSelectorVisible
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),

          // Spacer that adjusts with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isMonthYearSelectorVisible ? 16 : 16,
          ),

          // Calendar Content - Days of week and grid
          AnimatedOpacity(
            opacity: _isMonthYearSelectorVisible ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                // Day of week headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:
                      _weekdays
                          .map(
                            (day) => Expanded(
                              child: Text(
                                day.shortName,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),

                const SizedBox(height: 8),

                // Calendar grid with slide animation when month changes
                AnimatedBuilder(
                  animation: _slideController,
                  builder: (context, child) {
                    // Apply directional slide animation based on navigation direction
                    return Stack(
                      children: [
                        // Current month (sliding in)
                        SlideTransition(
                          position: _slideAnimation,
                          child: child,
                        ),

                        // Previous content (sliding out)
                        if (_slideController.value < 1.0)
                          SlideTransition(
                            position: Tween<Offset>(
                              // Slide out in opposite direction
                              begin: Offset.zero,
                              end: Offset(_isForward ? -1.0 : 1.0, 0.0),
                            ).animate(_slideController),
                            child: Opacity(
                              opacity: 1.0 - _slideController.value, // Fade out
                              child: IgnorePointer(
                                child: child,
                              ), // Prevent interaction
                            ),
                          ),
                      ],
                    );
                  },
                  child: GridView.builder(
                    key: ValueKey<String>(
                      '${_currentMonth.year}-${_currentMonth.month}',
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1,
                        ),
                    itemCount: 42, // 6 rows * 7 columns
                    itemBuilder: (context, index) {
                      // Calculate the day number
                      final dayNumber = index - firstWeekdayOfMonth + 1;
                      final isInCurrentMonth =
                          dayNumber > 0 && dayNumber <= daysInMonth;

                      if (isInCurrentMonth) {
                        final date = DateTime(
                          _currentMonth.year,
                          _currentMonth.month,
                          dayNumber,
                        );
                        final isDisabled = _isDateDisabled(date);

                        return CalendarDay(
                          date: date,
                          selectedDate: widget.selectedDate,
                          minDate: widget.minDate,
                          maxDate: widget.maxDate,
                          isInCurrentMonth: isInCurrentMonth,
                          isDisabled: isDisabled,
                          onDateSelected: isDisabled ? null : widget.onChange,
                        );
                      } else {
                        // Empty cell for days not in current month
                        return const SizedBox();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
