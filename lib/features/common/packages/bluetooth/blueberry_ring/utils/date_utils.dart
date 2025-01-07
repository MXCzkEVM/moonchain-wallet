class DateUtils {
  static bool isDateOnToday(
    DateTime date,
  ) {
    final now = DateTime.now();
    return isDateOnSpecificDay(date, now);
  }

  static bool isDateOnSpecificDay(DateTime date, DateTime targetDay) {
    final isTargetDay = targetDay.year == date.year &&
        targetDay.month == date.month &&
        targetDay.day == date.day;

    return isTargetDay;
  }
}
