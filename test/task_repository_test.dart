import 'dart:io';

import 'package:dewwit/repositories/task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late TaskRepository repository;

  setUp(() {
    sqfliteFfiInit();
    repository = TaskRepository.atPath(
      inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
  });

  tearDown(() async {
    await repository.close();
  });

  test('creates and reads a task', () async {
    final task = await repository.createTask('  Buy groceries  ');
    final tasks = await repository.getTasks();

    expect(task.id, greaterThan(0));
    expect(task.title, 'Buy groceries');
    expect(task.isCompleted, isFalse);
    expect(task.completedAt, isNull);
    expect(task.createdAt.isUtc, isTrue);
    expect(tasks, hasLength(1));
    expect(tasks.single.id, task.id);
    expect(tasks.single.title, task.title);
    expect(tasks.single.isCompleted, isFalse);
    expect(tasks.single.completedAt, isNull);
    expect(tasks.single.createdAt, task.createdAt);
  });

  test('rejects an empty task title', () async {
    expect(() => repository.createTask('   '), throwsA(isA<ArgumentError>()));
    expect(await repository.getTasks(), isEmpty);
  });

  test('toggles task completion in both directions', () async {
    final task = await repository.createTask('Review networking');

    final completedTask = await repository.toggleTask(task.id);
    final incompleteTask = await repository.toggleTask(task.id);

    expect(completedTask?.isCompleted, isTrue);
    expect(completedTask?.completedAt, isNotNull);
    expect(completedTask?.completedAt?.isUtc, isTrue);
    expect(incompleteTask?.isCompleted, isFalse);
    expect(incompleteTask?.completedAt, isNull);
    expect((await repository.getTasks()).single.isCompleted, isFalse);
  });

  test('returns null when toggling a task that does not exist', () async {
    expect(await repository.toggleTask(999), isNull);
  });

  test('deletes a task', () async {
    final task = await repository.createTask('Finish activity');

    expect(await repository.deleteTask(task.id), isTrue);
    expect(await repository.deleteTask(task.id), isFalse);
    expect(await repository.getTasks(), isEmpty);
  });

  test('keeps tasks after reopening the database', () async {
    final temporaryDirectory = await Directory.systemTemp.createTemp(
      'dewwit_test_',
    );
    final databasePath = '${temporaryDirectory.path}/dewwit.db';
    final firstRepository = TaskRepository.atPath(
      databasePath,
      factory: databaseFactoryFfi,
    );
    final secondRepository = TaskRepository.atPath(
      databasePath,
      factory: databaseFactoryFfi,
    );

    try {
      final task = await firstRepository.createTask('Persistent task');
      await firstRepository.close();

      final tasks = await secondRepository.getTasks();
      expect(tasks.single.id, task.id);
      expect(tasks.single.title, task.title);
    } finally {
      await firstRepository.close();
      await secondRepository.close();
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('orders active tasks before recently completed tasks', () async {
    final oldest = await repository.createTask('Oldest active');
    final middle = await repository.createTask('Middle active');
    await repository.createTask('Newest active');

    await repository.toggleTask(oldest.id);
    await Future<void>.delayed(const Duration(milliseconds: 2));
    await repository.toggleTask(middle.id);

    expect((await repository.getTasks()).map((task) => task.title), [
      'Newest active',
      'Middle active',
      'Oldest active',
    ]);
  });

  test(
    'migrates version 1 tasks and orders legacy completions safely',
    () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'dewwit_migration_test_',
      );
      final databasePath = '${temporaryDirectory.path}/dewwit.db';
      final oldDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, version) async {
            await database.execute('''
            CREATE TABLE tasks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              is_completed INTEGER NOT NULL,
              created_at INTEGER NOT NULL
            )
          ''');
            await database.insert('tasks', {
              'title': 'Legacy completed',
              'is_completed': 1,
              'created_at': 1000,
            });
            await database.insert('tasks', {
              'title': 'Legacy active',
              'is_completed': 0,
              'created_at': 2000,
            });
          },
        ),
      );
      await oldDatabase.close();

      final migratedRepository = TaskRepository.atPath(
        databasePath,
        factory: databaseFactoryFfi,
      );
      try {
        final tasks = await migratedRepository.getTasks();
        expect(tasks.map((task) => task.title), [
          'Legacy active',
          'Legacy completed',
        ]);
        expect(tasks.last.completedAt, isNull);

        final recompleted = await migratedRepository.toggleTask(tasks.last.id);
        expect(recompleted?.isCompleted, isFalse);
        expect(recompleted?.completedAt, isNull);
      } finally {
        await migratedRepository.close();
        await temporaryDirectory.delete(recursive: true);
      }
    },
  );
}
