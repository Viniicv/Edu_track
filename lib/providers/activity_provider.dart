import 'package:flutter/material.dart';
import '../models/activity_model.dart';

class ActivityProvider extends ChangeNotifier {
  List<Activity> _activities = [];
  
  List<Activity> get activities => _activities;
  
  ActivityProvider() {
    _loadMockData();
  }
  
  void _loadMockData() {
    final now = DateTime.now();
    _activities = [
      Activity(id: 1, title: 'Entrega Dispositivos móveis', subject: 'Dispositivos Móveis', dueDate: DateTime(now.year, now.month, now.day, 23, 59), isUrgent: true, progress: 50),
      Activity(id: 2, title: 'Entregar Back End', subject: 'Back End', dueDate: DateTime(now.year, now.month, now.day, 23, 59), isUrgent: true, progress: 30),
      Activity(id: 3, title: 'Entregar Front End', subject: 'Front End', dueDate: DateTime(now.year, now.month, now.day, 23, 59), isUrgent: true, progress: 70),
      Activity(id: 4, title: 'Prova Qualidade de Software', subject: 'Qualidade de Software', dueDate: DateTime(now.year, now.month, 22, 8, 0), isUrgent: false, progress: 0),
      Activity(id: 5, title: 'Prova Empreendedorismo', subject: 'Empreendedorismo', dueDate: DateTime(now.year, now.month, 22, 8, 0), isUrgent: false, progress: 0),
      Activity(id: 6, title: 'Entrega Residência de Software', subject: 'Residência de Software', dueDate: DateTime(now.year, now.month, now.day, 23, 59), isUrgent: true, progress: 20),
    ];
  }
  
  List<Activity> getTodayUrgentActivities() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _activities.where((a) => 
      a.dueDate.year == today.year && 
      a.dueDate.month == today.month && 
      a.dueDate.day == today.day && 
      a.isUrgent && !a.isCompleted
    ).toList();
  }

  List<Activity> getNextWeekActivities() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final nextWeek = today.add(const Duration(days: 7));

    return _activities.where((a) {
      final dueDate = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      return dueDate.isAfter(today) &&
          !dueDate.isAfter(nextWeek) &&
          !a.isCompleted;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
  
  List<Activity> getActivitiesByDate(DateTime date) {
    return _activities.where((a) => 
      a.dueDate.year == date.year && 
      a.dueDate.month == date.month && 
      a.dueDate.day == date.day
    ).toList();
  }
  
  void addActivity(Activity activity) {
    activity.id = _activities.length + 1;
    _activities.add(activity);
    notifyListeners();
  }
  
  void updateActivity(Activity activity) {
    final index = _activities.indexWhere((a) => a.id == activity.id);
    if (index != -1) {
      _activities[index] = activity;
      notifyListeners();
    }
  }
  
  void deleteActivity(int id) {
    _activities.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
