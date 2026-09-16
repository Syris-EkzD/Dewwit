import 'package:sqflite/sqflite.dart';

class KedisDatabase {
  KedisDatabase({DatabaseFactory? factory})
    : _factory = factory ?? databaseFactory,
      _databasePath = null;

  KedisDatabase.atPath(this._databasePath, {DatabaseFactory? factory})
    : _factory = factory ?? databaseFactory;

  // Retained for compatibility with the existing authoritative task store.
  static const databaseName = 'dewwit.db';
  static const databaseVersion = 2;
  static const tasksTable = 'tasks';

  final DatabaseFactory _factory;
  final String? _databasePath;
  Future<Database>? _database;

  Future<Database> get database => _database ??= _openDatabase();

  Future<void> close() async {
    final pendingDatabase = _database;
    if (pendingDatabase != null) {
      await (await pendingDatabase).close();
    }
    _database = null;
  }

  Future<Database> _openDatabase() async {
    final path =
        _databasePath ?? '${await _factory.getDatabasesPath()}/$databaseName';
    return _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE $tasksTable (
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
              'ALTER TABLE $tasksTable ADD COLUMN completed_at INTEGER',
            );
          }
        },
      ),
    );
  }
}
