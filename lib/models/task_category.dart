class TaskCategory {
  const TaskCategory({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.isSystem,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int colorValue;
  final bool isSystem;
  final DateTime createdAt;

  factory TaskCategory.fromMap(Map<String, Object?> map) {
    return TaskCategory(
      id: map['id']! as int,
      name: map['name']! as String,
      colorValue: map['color_value']! as int,
      isSystem: map['is_system']! as int == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at']! as int,
        isUtc: true,
      ),
    );
  }
}
