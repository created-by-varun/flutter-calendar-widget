import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_widget/calendar_widget.dart';

void main() {
  testWidgets('CalendarWidget initializes correctly', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CalendarWidget())),
    );

    // Verify the widget renders
    expect(find.byType(CalendarWidget), findsOneWidget);

    // Verify it shows the current month and year
    final now = DateTime.now();
    final currentMonth = CalendarDateUtils.formatMonthYear(now);
    expect(find.text(currentMonth), findsOneWidget);
  });

  test('CalendarDateUtils functions work correctly', () {
    final date = DateTime(2025, 8, 17);

    // Test formatDayMonth
    expect(CalendarDateUtils.formatDayMonth(date), 'Sun, Aug 17');

    // Test isSameDay
    expect(CalendarDateUtils.isSameDay(date, DateTime(2025, 8, 17)), true);
    expect(CalendarDateUtils.isSameDay(date, DateTime(2025, 8, 18)), false);
  });
}
