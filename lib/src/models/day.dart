enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

extension DayExtension on Day {
  // Returns the weekday number as used by DateTime.weekday (1-7, where 1 is Monday)
  int get weekdayNumber {
    switch (this) {
      case Day.monday:
        return 1;
      case Day.tuesday:
        return 2;
      case Day.wednesday:
        return 3;
      case Day.thursday:
        return 4;
      case Day.friday:
        return 5;
      case Day.saturday:
        return 6;
      case Day.sunday:
        return 7;
    }
  }

  String get shortName {
    switch (this) {
      case Day.monday:
        return 'M';
      case Day.tuesday:
        return 'T';
      case Day.wednesday:
        return 'W';
      case Day.thursday:
        return 'T';
      case Day.friday:
        return 'F';
      case Day.saturday:
        return 'S';
      case Day.sunday:
        return 'S';
    }
  }
}
