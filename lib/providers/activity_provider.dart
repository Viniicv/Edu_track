import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/auth_service.dart';

class ActivityProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _authSubscription;
  StreamSubscription? _activitiesSubscription;

  List<Activity> _activities = [];
  bool _isLoading = true;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;

  ActivityProvider() {
    _authSubscription = AuthService.instance.authStateChanges.listen((user) {
      final email = user?.email;
      if (!AuthService.isInstitutionalEmail(email)) {
        _clearActivities();
        return;
      }

      _listenToUserActivities(email!.trim().toLowerCase());
    });
  }

  void _listenToUserActivities(String userEmail) {
    _activitiesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _activitiesSubscription = _firestore
        .collection('activities')
        .where('usuario_logado', isEqualTo: userEmail)
        .snapshots()
        .listen((snapshot) {
      _activities = snapshot.docs.map(Activity.fromFirestore).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _activities = [];
      _isLoading = false;
      notifyListeners();
    });
  }

  void _clearActivities() {
    _activitiesSubscription?.cancel();
    _activities = [];
    _isLoading = false;
    notifyListeners();
  }

  List<Activity> getTodayUrgentActivities() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return _activities.where((activity) {
      return activity.dueDate.year == today.year &&
          activity.dueDate.month == today.month &&
          activity.dueDate.day == today.day &&
          activity.isUrgent &&
          !activity.isCompleted;
    }).toList();
  }

  List<Activity> getNextWeekActivities() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final nextWeek = today.add(const Duration(days: 7));

    return _activities.where((activity) {
      final dueDate = DateTime(
        activity.dueDate.year,
        activity.dueDate.month,
        activity.dueDate.day,
      );
      return dueDate.isAfter(today) &&
          !dueDate.isAfter(nextWeek) &&
          !activity.isCompleted;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<Activity> getActivitiesByDate(DateTime date) {
    return _activities.where((activity) {
      return activity.dueDate.year == date.year &&
          activity.dueDate.month == date.month &&
          activity.dueDate.day == date.day;
    }).toList();
  }

  Future<void> addActivity(Activity activity) async {
    final userEmail = _currentInstitutionalEmail();
    await _firestore.collection('activities').add(
          activity.toFirestore(
            userEmail: userEmail,
            isCreate: true,
          ),
        );
  }

  Future<void> updateActivity(Activity activity) async {
    final userEmail = _currentInstitutionalEmail();
    final id = activity.id;
    if (id == null) return;

    await _firestore.collection('activities').doc(id).update(
          activity.toFirestore(userEmail: userEmail),
        );
  }

  Future<void> deleteActivity(String id) async {
    _currentInstitutionalEmail();
    await _firestore.collection('activities').doc(id).delete();
  }

  String _currentInstitutionalEmail() {
    final email = AuthService.instance.currentUser?.email?.trim().toLowerCase();
    if (!AuthService.isInstitutionalEmail(email)) {
      throw const AuthDomainException();
    }

    return email!;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _activitiesSubscription?.cancel();
    super.dispose();
  }
}
