import '../models/activity_model.dart';
import 'date_helpers.dart' as date_helpers;

List<Activity> todayPendingActivities(
  List<Activity> activities, {
  required DateTime referenceDate,
}) {
  final today = date_helpers.dateOnly(referenceDate);

  return activities.where((activity) {
    return date_helpers.isSameDay(activity.dueDate, today) &&
        !activity.isCompleted;
  }).toList();
}

List<Activity> thisWeekPendingActivities(
  List<Activity> activities, {
  required DateTime referenceDate,
}) {
  final today = date_helpers.dateOnly(referenceDate);
  final startOfWeek = date_helpers.currentWeekSundayStart(today);
  final endOfWeek = date_helpers.currentWeekSaturdayEnd(today);

  return activities.where((activity) {
    return date_helpers.isDateBetweenInclusive(
          activity.dueDate,
          startOfWeek,
          endOfWeek,
        ) &&
        !date_helpers.isSameDay(activity.dueDate, today) &&
        !activity.isCompleted;
  }).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
}

List<Activity> nextWeekPendingActivities(
  List<Activity> activities, {
  required DateTime referenceDate,
}) {
  final startOfNextWeek = date_helpers.nextWeekSundayStart(referenceDate);
  final endOfNextWeek = date_helpers.nextWeekSaturdayEnd(referenceDate);

  return activities.where((activity) {
    return date_helpers.isDateBetweenInclusive(
          activity.dueDate,
          startOfNextWeek,
          endOfNextWeek,
        ) &&
        !activity.isCompleted;
  }).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
}
