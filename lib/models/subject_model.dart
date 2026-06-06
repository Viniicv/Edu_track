import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  String? id;
  String name;
  String color;
  int progress;
  int totalTasks;
  int completedTasks;
  String? usuarioLogado;
  DateTime? createdAt;
  DateTime? updatedAt;

  Subject({
    this.id,
    required this.name,
    required this.color,
    this.progress = 0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.usuarioLogado,
    this.createdAt,
    this.updatedAt,
  });

  factory Subject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Subject(
      id: document.id,
      name: data['name'] as String? ?? '',
      color: data['color'] as String? ?? '#1E3A8A',
      progress: data['progress'] as int? ?? 0,
      totalTasks: data['totalTasks'] as int? ?? 0,
      completedTasks: data['completedTasks'] as int? ?? 0,
      usuarioLogado: data['usuario_logado'] as String?,
      createdAt: _readDate(data['createdAt']),
      updatedAt: _readDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore({
    required String userEmail,
    bool isCreate = false,
  }) {
    return {
      'name': name.trim(),
      'color': color,
      'progress': progress,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'usuario_logado': userEmail,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
