import 'package:flutter/material.dart';
import '../models/subject_model.dart';

class SubjectProvider extends ChangeNotifier {
  List<Subject> _subjects = [];
  
  List<Subject> get subjects => _subjects;
  
  SubjectProvider() {
    _subjects = [
      Subject(id: 1, name: 'Dispositivos Móveis', color: '#6366F1', progress: 100),
      Subject(id: 2, name: 'Banco de Dados', color: '#10B981', progress: 80),
      Subject(id: 3, name: 'Front End', color: '#F59E0B', progress: 70),
      Subject(id: 4, name: 'Back End', color: '#EF4444', progress: 75),
      Subject(id: 5, name: 'Qualidade de Software', color: '#8B5CF6', progress: 50),
      Subject(id: 6, name: 'Engenharia de Software', color: '#EC4899', progress: 10),
      Subject(id: 7, name: 'Governança de TI', color: '#06B6D4', progress: 30),
    ];
  }
  
  void addSubject(Subject subject) {
    subject.id = _subjects.length + 1;
    _subjects.add(subject);
    notifyListeners();
  }
  
  void updateSubject(Subject subject) {
    final index = _subjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      _subjects[index] = subject;
      notifyListeners();
    }
  }
  
  void deleteSubject(int id) {
    _subjects.removeWhere((s) => s.id == id);
    notifyListeners();
  }
  
  Subject? getSubjectById(int id) {
    try {
      return _subjects.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}