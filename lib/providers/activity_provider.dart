import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/auth_service.dart';
import '../utils/activity_filters.dart' as activity_filters;
import '../utils/activity_validators.dart' as activity_validators;
import '../utils/date_helpers.dart' as date_helpers;

class DuplicateActivityException implements Exception {
  const DuplicateActivityException();
}

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

      _listenToUserActivities(email!.trim());
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

  List<Activity> getTodayPendingActivities() {
    return activity_filters.todayPendingActivities(
      _activities,
      referenceDate: DateTime.now(),
    );
  }

  List<Activity> getNextWeekPendingActivities() {
    return activity_filters.nextWeekPendingActivities(
      _activities,
      referenceDate: DateTime.now(),
    );
  }

  List<Activity> getThisWeekPendingActivities() {
    return activity_filters.thisWeekPendingActivities(
      _activities,
      referenceDate: DateTime.now(),
    );
  }

  List<Activity> getActivitiesByDate(DateTime date) {
    return _activities.where((activity) {
      return date_helpers.isSameDay(activity.dueDate, date);
    }).toList();
  }

  Future<void> addActivity(Activity activity) async {
    final userEmail = _currentInstitutionalEmail();
    if (activity_validators.hasDuplicateActivity(_activities, activity)) {
      throw const DuplicateActivityException();
    }

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
    final email = AuthService.instance.currentUser?.email?.trim();
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
