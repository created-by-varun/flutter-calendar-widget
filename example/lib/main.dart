import 'package:flutter/material.dart';
import 'package:calendar_widget/calendar_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar Widget Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calendar Widget Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _selectedDate;
  DateTime? _minDate;
  DateTime? _maxDate;
  List<Day> _disabledDays = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2025, 8, 17); // Start with Aug 17, 2025 selected
    _minDate = DateTime(2025, 8, 1); // Can't select dates before Aug 1, 2025
    _maxDate = DateTime(2025, 8, 31); // Can't select dates after Aug 31, 2025
    _disabledDays = [Day.sunday]; // Disable Sundays by default
  }

  void _onDateChanged(DateTime date) {
    print('Date selected: $date');
    // Explicitly update the state with the new date
    setState(() {
      _selectedDate = date;
    });
  }

  void _toggleDisabledDay(Day day) {
    setState(() {
      if (_disabledDays.contains(day)) {
        _disabledDays.remove(day); // Remove day if already in the list
      } else {
        _disabledDays.add(day); // Add day if not in the list
      }
    });
  }

  void _showCalendarBottomSheet() {
    // Use a more flexible approach with DraggableScrollableSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // Initial height (60% of screen)
          minChildSize: 0.4, // Min height (40% of screen)
          maxChildSize: 0.9, // Max height (90% of screen)
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bottom sheet header with handle and close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // For balance
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      // Close button
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  // Calendar in a scrollable container
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: StatefulBuilder(
                          builder: (context, setModalState) {
                            return CalendarWidget(
                              key: ValueKey(_selectedDate.toString()), // Force rebuild on selection
                              selectedDate: _selectedDate,
                              minDate: _minDate,
                              maxDate: _maxDate,
                              disabledDays: _disabledDays,
                              onChange: (date) {
                                _onDateChanged(date);
                                // Update state within the modal too
                                setModalState(() {});
                                // Don't automatically close the bottom sheet after selection
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show selected date
            Card(
              elevation: 2,
              child: InkWell(
                onTap: _showCalendarBottomSheet,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'No date selected'
                                : CalendarDateUtils.formatDayMonth(
                                  _selectedDate!,
                                ),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Controls
            Text('Controls', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Min Date Control
            Row(
              children: [
                const Text('Min Date:'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _minDate = _minDate == null ? DateTime(2025, 8, 1) : null;
                    });
                  },
                  child: Text(
                    _minDate == null ? 'Set Min Date' : 'Clear Min Date',
                  ),
                ),
              ],
            ),

            // Max Date Control
            Row(
              children: [
                const Text('Max Date:'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _maxDate =
                          _maxDate == null ? DateTime(2025, 8, 31) : null;
                    });
                  },
                  child: Text(
                    _maxDate == null ? 'Set Max Date' : 'Clear Max Date',
                  ),
                ),
              ],
            ),

            // Disabled Day
            const SizedBox(height: 8),
            const Text('Disabled Day of Week:'),
            Wrap(
              spacing: 8,
              children:
                  Day.values.map((day) {
                    return FilterChip(
                      label: Text(day.name),
                      selected: _disabledDays.contains(day),
                      onSelected: (_) => _toggleDisabledDay(day),
                    );
                  }).toList(),
            ),

            // Selected Date Info
            const SizedBox(height: 32),
            Text(
              'Selected Date:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'No date selected'
                          : CalendarDateUtils.formatDayMonth(_selectedDate!),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Day of week: ${Day.values[_selectedDate!.weekday - 1].name}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
