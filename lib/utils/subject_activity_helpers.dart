import '../models/activity_model.dart';
import '../models/subject_model.dart';

List<Activity> linkedActivitiesForSubject(
  Subject subject,
  List<Activity> activities,
) {
  return activities.where((activity) {
    return isActivityLinkedToSubject(activity, subject);
  }).toList();
}

bool hasLinkedActivities(
  Subject subject,
  List<Activity> activities,
) {
  return linkedActivitiesForSubject(subject, activities).isNotEmpty;
}

bool isActivityLinkedToSubject(Activity activity, Subject subject) {
  final subjectId = subject.id?.trim();
  final activitySubjectId = activity.subjectId?.trim();
  final hasSubjectId = subjectId != null && subjectId.isNotEmpty;
  final hasActivitySubjectId =
      activitySubjectId != null && activitySubjectId.isNotEmpty;

  if (hasSubjectId && hasActivitySubjectId && activitySubjectId == subjectId) {
    return true;
  }

  return _normalize(activity.subject) == _normalize(subject.name);
}

int calculateSubjectProgress(List<Activity> linkedActivities) {
  if (linkedActivities.isEmpty) return 0;

  final completed =
      linkedActivities.where((activity) => activity.isCompleted).length;
  return ((completed / linkedActivities.length) * 100).round();
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}
