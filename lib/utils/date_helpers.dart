DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool isSameDay(DateTime a, DateTime b) {
  final firstDate = dateOnly(a);
  final secondDate = dateOnly(b);

  return firstDate.year == secondDate.year &&
      firstDate.month == secondDate.month &&
      firstDate.day == secondDate.day;
}

DateTime currentWeekSundayStart(DateTime referenceDate) {
  final date = dateOnly(referenceDate);
  return date.subtract(Duration(days: date.weekday % 7));
}

DateTime currentWeekSaturdayEnd(DateTime referenceDate) {
  return currentWeekSundayStart(referenceDate).add(const Duration(days: 6));
}

DateTime nextWeekSundayStart(DateTime referenceDate) {
  return currentWeekSundayStart(referenceDate).add(const Duration(days: 7));
}

DateTime nextWeekSaturdayEnd(DateTime referenceDate) {
  return nextWeekSundayStart(referenceDate).add(const Duration(days: 6));
}

bool isDateBetweenInclusive(
  DateTime date,
  DateTime start,
  DateTime end,
) {
  final targetDate = dateOnly(date);
  final startDate = dateOnly(start);
  final endDate = dateOnly(end);

  return !targetDate.isBefore(startDate) && !targetDate.isAfter(endDate);
}
