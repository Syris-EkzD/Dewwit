import 'package:dewwit/models/task.dart';
import 'package:sqflite/sqflite.dart';

class TaskRepository {
  TaskRepository({DatabaseFactory? factory})
    : _factory = factory ?? databaseFactory,
      _databasePath = null;

  TaskRepository.atPath(this._databasePath, {DatabaseFactory? factory})
    : _factory = factory ?? databaseFactory;

  static const _databaseName = 'dewwit.db';
  static const _databaseVersion = 2;
  static const _tasksTable = 'tasks';

  final DatabaseFactory _factory;
  final String? _databasePath;
  Future<Database>? _database;

  Future<Task> createTask(String title) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Task title cannot be empty.');
    }

    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch,
      isUtc: true,
    );
    final database = await _getDatabase();
    final id = await database.insert(_tasksTable, {
      'title': normalizedTitle,
      'is_completed': 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'completed_at': null,
    });

    return Task(
      id: id,
      title: normalizedTitle,
      isCompleted: false,
      createdAt: createdAt,
      completedAt: null,
    );
  }

  Future<List<Task>> getTasks() async {
    final database = await _getDatabase();
    final rows = await database.query(
      _tasksTable,
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

  Future<Task?> toggleTask(int id) async {
    final database = await _getDatabase();

    return database.transaction((transaction) async {
      final updatedRows = await transaction.rawUpdate(
        '''
        UPDATE $_tasksTable
        SET completed_at = CASE is_completed WHEN 0 THEN ? ELSE NULL END,
            is_completed = CASE is_completed WHEN 0 THEN 1 ELSE 0 END
        WHERE id = ?
        ''',
        [DateTime.now().millisecondsSinceEpoch, id],
      );
      if (updatedRows == 0) {
        return null;
      }

      final rows = await transaction.query(
        _tasksTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return Task.fromMap(rows.single);
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

    final database = await _getDatabase();
    return database.transaction((transaction) async {
      final updatedRows = await transaction.update(
        _tasksTable,
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

      final rows = await transaction.query(
        _tasksTable,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return Task.fromMap(rows.single);
    });
  }

  Future<bool> deleteTask(int id) async {
    final database = await _getDatabase();
    final deletedRows = await database.delete(
      _tasksTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    return deletedRows > 0;
  }

  Future<void> close() async {
    final database = _database;
    if (database != null) {
      await (await database).close();
    }
    _database = null;
  }

  Future<Database> _getDatabase() async {
    return _database ??= _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final path =
        _databasePath ?? '${await _factory.getDatabasesPath()}/$_databaseName';
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE $_tasksTable (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL CHECK(length(trim(title)) > 0),
              is_completed INTEGER NOT NULL DEFAULT 0
                CHECK(is_completed IN (0, 1)),
              created_at INTEGER NOT NULL,
              completed_at INTEGER
            )
          ''');
        },
        onUpgrade: (database, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await database.execute(
              'ALTER TABLE $_tasksTable ADD COLUMN completed_at INTEGER',
            );
          }
        },
      ),
    );
  }
}
