import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String? id;
  String title;
  String subject;
  DateTime dueDate;
  bool isUrgent;
  bool isCompleted;
  int progress;
  String? usuarioLogado;
  DateTime? createdAt;
  DateTime? updatedAt;

  Activity({
    this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.isUrgent = false,
    this.isCompleted = false,
    this.progress = 0,
    this.usuarioLogado,
    this.createdAt,
    this.updatedAt,
  });

  factory Activity.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    return Activity(
      id: document.id,
      title: data['title'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      dueDate: _readDate(data['dueDate']) ?? DateTime.now(),
      isUrgent: data['isUrgent'] as bool? ?? false,
      isCompleted: data['isCompleted'] as bool? ?? false,
      progress: data['progress'] as int? ?? 0,
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
      'title': title.trim(),
      'subject': subject.trim(),
      'dueDate': Timestamp.fromDate(dueDate),
      'isUrgent': isUrgent,
      'isCompleted': isCompleted,
      'progress': progress,
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
