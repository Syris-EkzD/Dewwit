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
    expect(task.createdAt.isUtc, isTrue);
    expect(tasks, hasLength(1));
    expect(tasks.single.id, task.id);
    expect(tasks.single.title, task.title);
    expect(tasks.single.isCompleted, isFalse);
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
    expect(incompleteTask?.isCompleted, isFalse);
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
}
