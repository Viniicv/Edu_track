class Task {
  int? id;
  String title;
  String description;
  DateTime deadline;
  int subjectId;
  bool isCompleted;
  int progress; // 0-100
  
  Task({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.subjectId,
    this.isCompleted = false,
    this.progress = 0,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'subjectId': subjectId,
      'isCompleted': isCompleted ? 1 : 0,
      'progress': progress,
    };
  }
  
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      deadline: DateTime.parse(map['deadline']),
      subjectId: map['subjectId'],
      isCompleted: map['isCompleted'] == 1,
      progress: map['progress'],
    );
  }
}