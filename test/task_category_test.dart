import 'package:kedis/repositories/category_repository.dart';
import 'package:kedis/repositories/kedis_database.dart';
import 'package:kedis/repositories/task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late KedisDatabase database;
  late CategoryRepository categories;
  late TaskRepository tasks;

  setUp(() {
    sqfliteFfiInit();
    database = KedisDatabase.atPath(
      inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    categories = CategoryRepository.withDatabase(database);
    tasks = TaskRepository.withDatabase(database);
  });

  tearDown(() => database.close());

  test('quick-capture task defaults to Inbox', () async {
    final inbox = await categories.getInbox();

    final task = await tasks.createTask('Quick capture');

    expect(task.categoryId, inbox.id);
    expect((await tasks.getTasks(categoryId: inbox.id)).single.id, task.id);
  });

  test('task created for a custom category stays in that category', () async {
    final school = await categories.createCategory('School', 0xFF6750A4);

    final task = await tasks.createTask('Database proposal', categoryId: school.id);

    expect(task.categoryId, school.id);
    expect((await tasks.getTasks(categoryId: school.id)).single.id, task.id);
  });

  test('moves a task without changing completion state or timestamps', () async {
    final school = await categories.createCategory('School', 0xFF6750A4);
    final programming = await categories.createCategory(
      'Programming',
      0xFF006C4C,
    );
    final created = await tasks.createTask(
      'Finish migration',
      categoryId: school.id,
    );
    final completedAt = DateTime.utc(2026, 9, 16, 12, 30);
    final completed = await tasks.setTaskCompletion(
      created.id,
      isCompleted: true,
      completedAt: completedAt,
    );

    final moved = await tasks.moveTaskToCategory(created.id, programming.id);

    expect(moved?.categoryId, programming.id);
    expect(moved?.id, completed?.id);
    expect(moved?.title, completed?.title);
    expect(moved?.createdAt, completed?.createdAt);
    expect(moved?.isCompleted, isTrue);
    expect(moved?.completedAt, completedAt);
    expect(await tasks.getTasks(categoryId: school.id), isEmpty);
    expect((await tasks.getTasks(categoryId: programming.id)).single.id, created.id);
  });

  test('active task queries preserve creation ordering inside a category', () async {
    final category = await categories.createCategory('School', 0xFF6750A4);
    final first = await tasks.createTask('First', categoryId: category.id);
    final second = await tasks.createTask('Second', categoryId: category.id);
    await tasks.setTaskCompletion(
      first.id,
      isCompleted: true,
      completedAt: DateTime.utc(2026, 9, 16, 13),
    );

    final active = await tasks.getActiveTasks(categoryId: category.id);

    expect(active.map((task) => task.id), [second.id]);
  });
}
