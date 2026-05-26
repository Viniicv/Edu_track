class Subject {
  int? id;
  String name;
  String color;
  int progress;
  int totalTasks;
  int completedTasks;
  
  Subject({
    this.id,
    required this.name,
    required this.color,
    this.progress = 0,
    this.totalTasks = 0,
    this.completedTasks = 0,
  });
}