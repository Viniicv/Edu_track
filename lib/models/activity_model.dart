class Activity {
  int? id;
  String title;
  String subject;
  DateTime dueDate;
  bool isUrgent;
  bool isCompleted;
  int progress;
  
  Activity({
    this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.isUrgent = false,
    this.isCompleted = false,
    this.progress = 0,
  });
}