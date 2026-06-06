import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../services/auth_service.dart';

class SubjectProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _authSubscription;
  StreamSubscription? _subjectsSubscription;

  List<Subject> _subjects = [];
  bool _isLoading = true;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  SubjectProvider() {
    _authSubscription = AuthService.instance.authStateChanges.listen((user) {
      final email = user?.email;
      if (!AuthService.isInstitutionalEmail(email)) {
        _clearSubjects();
        return;
      }

      _listenToUserSubjects(email!.trim().toLowerCase());
    });
  }

  void _listenToUserSubjects(String userEmail) {
    _subjectsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subjectsSubscription = _firestore
        .collection('subjects')
        .where('usuario_logado', isEqualTo: userEmail)
        .snapshots()
        .listen((snapshot) {
      _subjects = snapshot.docs.map(Subject.fromFirestore).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _subjects = [];
      _isLoading = false;
      notifyListeners();
    });
  }

  void _clearSubjects() {
    _subjectsSubscription?.cancel();
    _subjects = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSubject(Subject subject) async {
    final userEmail = _currentInstitutionalEmail();
    await _firestore.collection('subjects').add(
          subject.toFirestore(
            userEmail: userEmail,
            isCreate: true,
          ),
        );
  }

  Future<void> updateSubject(Subject subject) async {
    final userEmail = _currentInstitutionalEmail();
    final id = subject.id;
    if (id == null) return;

    await _firestore.collection('subjects').doc(id).update(
          subject.toFirestore(userEmail: userEmail),
        );
  }

  Future<void> deleteSubject(String id) async {
    _currentInstitutionalEmail();
    await _firestore.collection('subjects').doc(id).delete();
  }

  Subject? getSubjectById(String id) {
    try {
      return _subjects.firstWhere((subject) => subject.id == id);
    } catch (_) {
      return null;
    }
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
    _subjectsSubscription?.cancel();
    super.dispose();
  }
}
