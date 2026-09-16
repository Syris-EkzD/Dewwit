import 'package:kedis/models/task.dart';
import 'package:kedis/repositories/kedis_database.dart';
import 'package:sqflite/sqflite.dart';

class TaskRepository {
  TaskRepository({DatabaseFactory? factory})
    : _database = KedisDatabase(factory: factory),
      _ownsDatabase = true;

  TaskRepository.atPath(String databasePath, {DatabaseFactory? factory})
    : _database = KedisDatabase.atPath(databasePath, factory: factory),
      _ownsDatabase = true;

  TaskRepository.withDatabase(this._database) : _ownsDatabase = false;

  final KedisDatabase _database;
  final bool _ownsDatabase;

  Future<Task> createTask(String title, {int? categoryId}) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Task title cannot be empty.');
    }

    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch,
      isUtc: true,
    );
    final database = await _database.database;
    final resolvedCategoryId =
        categoryId ?? await KedisDatabase.getInboxId(database);
    final id = await database.insert(KedisDatabase.tasksTable, {
      'title': normalizedTitle,
      'is_completed': 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'completed_at': null,
      'category_id': resolvedCategoryId,
    });

    return Task(
      id: id,
      title: normalizedTitle,
      isCompleted: false,
      createdAt: createdAt,
      completedAt: null,
      categoryId: resolvedCategoryId,
    );
  }

  Future<List<Task>> getTasks() async {
    final database = await _database.database;
    final rows = await database.query(
      KedisDatabase.tasksTable,
      orderBy: '''
        is_completed ASC,
        CASE WHEN completed_at IS NULL THEN 1 ELSE 0 END ASC,
        completed_at DESC,
        created_at ASC,
        id ASC
      ''',
    );

    return rows.map(Task.fromMap).toList(growable: false);
  }

  Future<Task?> updateTaskTitle(int id, String title) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Task title cannot be empty.');
    }

    final database = await _database.database;
    final updatedRows = await database.update(
      KedisDatabase.tasksTable,
      {'title': normalizedTitle},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updatedRows == 0) {
      return null;
    }

    return _getTask(database, id);
  }

  Future<Task?> toggleTask(int id) async {
    final database = await _database.database;

    return database.transaction((transaction) async {
      final updatedRows = await transaction.rawUpdate(
        '''
        UPDATE ${KedisDatabase.tasksTable}
        SET completed_at = CASE is_completed WHEN 0 THEN ? ELSE NULL END,
            is_completed = CASE is_completed WHEN 0 THEN 1 ELSE 0 END
        WHERE id = ?
        ''',
        [DateTime.now().millisecondsSinceEpoch, id],
      );
      if (updatedRows == 0) {
        return null;
      }

      return _getTask(transaction, id);
    });
  }

  Future<Task?> setTaskCompletion(
    int id, {
    required bool isCompleted,
    required DateTime? completedAt,
  }) async {
    if (isCompleted && completedAt == null) {
      throw ArgumentError.notNull('completedAt');
    }

    final database = await _database.database;
    return database.transaction((transaction) async {
      final updatedRows = await transaction.update(
        KedisDatabase.tasksTable,
        {
          'is_completed': isCompleted ? 1 : 0,
          'completed_at': isCompleted
              ? completedAt!.millisecondsSinceEpoch
              : null,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      if (updatedRows == 0) {
        return null;
      }

      return _getTask(transaction, id);
    });
  }

  Future<bool> deleteTask(int id) async {
    final database = await _database.database;
    final deletedRows = await database.delete(
      KedisDatabase.tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    return deletedRows > 0;
  }

  Future<Task> restoreTask(Task task) async {
    final database = await _database.database;
    await database.insert(KedisDatabase.tasksTable, {
      'id': task.id,
      'title': task.title,
      'is_completed': task.isCompleted ? 1 : 0,
      'created_at': task.createdAt.millisecondsSinceEpoch,
      'completed_at': task.completedAt?.millisecondsSinceEpoch,
      'category_id': task.categoryId,
    });
    return task;
  }

  Future<void> close() async {
    if (_ownsDatabase) {
      await _database.close();
    }
  }

  Future<Task?> _getTask(DatabaseExecutor database, int id) async {
    final rows = await database.query(
      KedisDatabase.tasksTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Task.fromMap(rows.single);
  }
}
