import '../models/activity_model.dart';

bool hasDuplicateActivity(
  List<Activity> activities,
  Activity newActivity,
) {
  final newTitle = _normalize(newActivity.title);

  return activities.any((activity) {
    return _normalize(activity.title) == newTitle &&
        _isSameSubject(activity, newActivity);
  });
}

bool _isSameSubject(Activity activity, Activity newActivity) {
  final activitySubjectId = _normalizeNullable(activity.subjectId);
  final newSubjectId = _normalizeNullable(newActivity.subjectId);

  if (activitySubjectId != null && newSubjectId != null) {
    return activitySubjectId == newSubjectId;
  }

  return _normalize(activity.subject) == _normalize(newActivity.subject);
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}

String? _normalizeNullable(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
