# Calendar Widget

A beautiful, animated calendar widget for Flutter applications. This widget provides a modern, customizable calendar with smooth transitions and micro-animations for a premium user experience.

![Calendar Widget Demo](https://example.com/calendar_demo.gif)

## Features

- 🎭 **Smooth animations** - Elegant transitions when navigating between months, years, and when selecting dates
- 📅 **Month and year selection** - Easy navigation with month/year picker
- 🚫 **Date constraints** - Set minimum and maximum selectable dates
- 🔒 **Disable specific days** - Restrict selection of certain days of the week
- 🗓️ **Smart month disabling** - Automatically disables months that don't have any valid selectable dates
- 🎨 **Customizable appearance** - Easily style to match your app's theme
- 📱 **Responsive design** - Works beautifully on all screen sizes

## Installation

```yaml
dependencies:
  calendar_widget: ^1.0.0
```

Run `flutter pub get` to install the package.

## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:calendar_widget/calendar_widget.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Calendar Demo')),
        body: Center(
          child: CalendarWidget(
            selectedDate: DateTime.now(),
            onChange: (date) {
              print('Selected date: $date');
            },
          ),
        ),
      ),
    );
  }
}
```

## Advanced Usage

### Date Constraints

Limit the range of selectable dates:

```dart
CalendarWidget(
  selectedDate: DateTime.now(),
  minDate: DateTime(2025, 1, 1),  // Can't select dates before Jan 1, 2025
  maxDate: DateTime(2025, 12, 31), // Can't select dates after Dec 31, 2025
  onChange: (date) {
    print('Selected date: $date');
  },
)
```

### Disable Specific Days of Week

Prevent selection of specific days of the week (e.g., weekends):

```dart
CalendarWidget(
  selectedDate: DateTime.now(),
  disabledDays: [Day.saturday, Day.sunday], // Weekend days can't be selected
  onChange: (date) {
    print('Selected date: $date');
  },
)
```

### Using in a Bottom Sheet

Show the calendar in a modal bottom sheet:

```dart
void _showCalendarBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
              children: [
                // Bottom sheet header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                // Calendar widget
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CalendarWidget(
                      selectedDate: _selectedDate,
                      minDate: _minDate,
                      maxDate: _maxDate,
                      disabledDays: _disabledDays,
                      onChange: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                        // Note: Do not close the bottom sheet here to allow
                        // for multiple date selections
                      },
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
```

## CalendarWidget Properties

| Property       | Type                      | Description                                                 |
| -------------- | ------------------------- | ----------------------------------------------------------- |
| `selectedDate` | `DateTime?`               | The currently selected date (optional)                      |
| `minDate`      | `DateTime?`               | Minimum selectable date (optional)                          |
| `maxDate`      | `DateTime?`               | Maximum selectable date (optional)                          |
| `disabledDays` | `List<Day>?`              | List of days of the week that should be disabled (optional) |
| `onChange`     | `ValueChanged<DateTime>?` | Callback when a date is selected (optional)                 |

## Example App

The package includes a full example app that demonstrates all features. Run the example from the `/example` directory:

```
cd example
flutter run
```

## Credits

Developed by Edmo Labs.

## License

MIT License
