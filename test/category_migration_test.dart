import 'dart:io';

import 'package:kedis/repositories/kedis_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test('migrates schema v2 tasks into Inbox without losing task state', () async {
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'kedis_category_migration_',
    );
    final databasePath = '${temporaryDirectory.path}/dewwit.db';

    try {
      final oldDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (database, version) async {
            await database.execute('''
              CREATE TABLE tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL CHECK(length(trim(title)) > 0),
                is_completed INTEGER NOT NULL DEFAULT 0
                  CHECK(is_completed IN (0, 1)),
                created_at INTEGER NOT NULL,
                completed_at INTEGER
              )
            ''');
          },
        ),
      );
      await oldDatabase.insert('tasks', {
        'id': 7,
        'title': 'Legacy active',
        'is_completed': 0,
        'created_at': 1000,
        'completed_at': null,
      });
      await oldDatabase.insert('tasks', {
        'id': 11,
        'title': 'Legacy completed',
        'is_completed': 1,
        'created_at': 2000,
        'completed_at': 3000,
      });
      await oldDatabase.close();

      final kedisDatabase = KedisDatabase.atPath(
        databasePath,
        factory: databaseFactoryFfi,
      );
      final migrated = await kedisDatabase.database;

      expect(await migrated.getVersion(), KedisDatabase.databaseVersion);

      final categories = await migrated.query(KedisDatabase.categoriesTable);
      expect(categories, hasLength(1));
      expect(categories.single['name'], KedisDatabase.inboxName);
      expect(categories.single['system_key'], KedisDatabase.inboxSystemKey);
      expect(categories.single['is_system'], 1);

      final inboxId = categories.single['id']! as int;
      final tasks = await migrated.query(
        KedisDatabase.tasksTable,
        orderBy: 'id ASC',
      );
      expect(tasks, hasLength(2));
      expect(tasks[0]['id'], 7);
      expect(tasks[0]['title'], 'Legacy active');
      expect(tasks[0]['is_completed'], 0);
      expect(tasks[0]['created_at'], 1000);
      expect(tasks[0]['completed_at'], isNull);
      expect(tasks[0]['category_id'], inboxId);
      expect(tasks[1]['id'], 11);
      expect(tasks[1]['title'], 'Legacy completed');
      expect(tasks[1]['is_completed'], 1);
      expect(tasks[1]['created_at'], 2000);
      expect(tasks[1]['completed_at'], 3000);
      expect(tasks[1]['category_id'], inboxId);

      await kedisDatabase.close();
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('creates Inbox exactly once across repeated database opens', () async {
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'kedis_inbox_once_',
    );
    final databasePath = '${temporaryDirectory.path}/dewwit.db';

    try {
      for (var open = 0; open < 2; open += 1) {
        final kedisDatabase = KedisDatabase.atPath(
          databasePath,
          factory: databaseFactoryFfi,
        );
        final database = await kedisDatabase.database;
        final inboxRows = await database.query(
          KedisDatabase.categoriesTable,
          where: 'system_key = ?',
          whereArgs: [KedisDatabase.inboxSystemKey],
        );
        expect(inboxRows, hasLength(1));
        await kedisDatabase.close();
      }
    } finally {
      await temporaryDirectory.delete(recursive: true);
    }
  });
}
