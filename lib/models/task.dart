class Task {
  const Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  final int id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  factory Task.fromMap(Map<String, Object?> map) {
    return Task(
      id: map['id']! as int,
      title: map['title']! as String,
      isCompleted: map['is_completed']! as int == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at']! as int,
        isUtc: true,
      ),
    );
  }
}
