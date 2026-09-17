import 'package:kedis/main.dart';
import 'package:kedis/repositories/category_repository.dart';
import 'package:kedis/repositories/kedis_database.dart';
import 'package:kedis/repositories/task_repository.dart';
import 'package:kedis/settings/theme_controller.dart';
import 'package:kedis/settings/theme_preference_store.dart';
import 'package:kedis/widgets/editable_task_item.dart';
import 'package:kedis/widgets/editing_task_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late KedisDatabase database;
  late TaskRepository tasks;
  late CategoryRepository categories;
  late _FakeThemePreferenceStore themePreferenceStore;
  late int widgetRefreshCount;

  setUp(() {
    sqfliteFfiInit();
    database = KedisDatabase.atPath(
      inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    tasks = TaskRepository.withDatabase(database);
    categories = CategoryRepository.withDatabase(database);
    themePreferenceStore = _FakeThemePreferenceStore();
    widgetRefreshCount = 0;
  });

  tearDown(() => database.close());

  Future<void> pumpKedis(WidgetTester tester) async {
    await tester.pumpWidget(
      KedisApp(
        taskRepository: tasks,
        categoryRepository: categories,
        themeController: ThemeController(themePreferenceStore),
        widgetRefresh: () async {
          widgetRefreshCount += 1;
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openCategory(WidgetTester tester, String name) async {
    await tester.tap(find.text(name).first);
    await tester.pumpAndSettle();
  }

  testWidgets('shows category cards with a three-task active preview', (
    WidgetTester tester,
  ) async {
    final school = await categories.createCategory('School', 0xFF6750A4);
    for (final title in ['One', 'Two', 'Three', 'Four']) {
      await tasks.createTask(title, categoryId: school.id);
    }
    final completed = await tasks.createTask(
      'Completed',
      categoryId: school.id,
    );
    await tasks.setTaskCompletion(
      completed.id,
      isCompleted: true,
      completedAt: DateTime.utc(2026, 9, 16, 12),
    );

    await pumpKedis(tester);

    expect(find.text('Inbox'), findsOneWidget);
    expect(find.text('School'), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
    expect(find.text('Four'), findsNothing);
    expect(find.text('Completed'), findsNothing);
    expect(find.text('+1 more'), findsOneWidget);
  });

  testWidgets('home quick capture creates a task in Inbox', (
    WidgetTester tester,
  ) async {
    final inbox = await categories.getInbox();
    await pumpKedis(tester);

    await tester.tap(find.byTooltip('Add task to Inbox'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Quick capture  ');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    final created = (await tasks.getTasks()).single;
    expect(created.title, 'Quick capture');
    expect(created.categoryId, inbox.id);
    expect(widgetRefreshCount, 1);
    expect(find.text('Quick capture'), findsOneWidget);
  });

  testWidgets('tapping a category opens its full task list', (
    WidgetTester tester,
  ) async {
    final school = await categories.createCategory('School', 0xFF6750A4);
    for (final title in ['One', 'Two', 'Three', 'Four']) {
      await tasks.createTask(title, categoryId: school.id);
    }

    await pumpKedis(tester);
    expect(find.text('Four'), findsNothing);
    await openCategory(tester, 'School');

    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('Three'), findsOneWidget);
    expect(find.text('Four'), findsOneWidget);
  });

  testWidgets('category inline capture assigns the current category', (
    WidgetTester tester,
  ) async {
    final school = await categories.createCategory('School', 0xFF6750A4);
    await pumpKedis(tester);
    await openCategory(tester, 'School');

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    expect(find.byType(EditableTaskItem), findsOneWidget);
    expect(find.byTooltip('Add task'), findsNothing);

    await tester.enterText(find.byType(TextField), '  Database proposal  ');
    await tester.tap(find.byTooltip('Save task'));
    await tester.pumpAndSettle();

    final created = (await tasks.getTasks(categoryId: school.id)).single;
    expect(created.title, 'Database proposal');
    expect(created.categoryId, school.id);
    expect(find.text('Database proposal'), findsOneWidget);
    expect(widgetRefreshCount, 1);
  });

  testWidgets('empty inline draft is discarded without persistence', (
    WidgetTester tester,
  ) async {
    await pumpKedis(tester);
    await openCategory(tester, 'Inbox');

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Discard draft'));
    await tester.pumpAndSettle();

    expect(find.byType(EditableTaskItem), findsNothing);
    expect(await tasks.getTasks(), isEmpty);
    expect(widgetRefreshCount, 0);
  });

  testWidgets('edits a task title without changing task state', (
    WidgetTester tester,
  ) async {
    final inbox = await categories.getInbox();
    final original = await tasks.createTask('Original title');
    await pumpKedis(tester);
    await openCategory(tester, 'Inbox');

    await tester.tap(find.text('Original title'));
    await tester.pumpAndSettle();
    expect(find.byType(EditingTaskItem), findsOneWidget);
    await tester.enterText(find.byType(TextField), '  Updated title  ');
    await tester.tap(find.byTooltip('Save changes'));
    await tester.pumpAndSettle();

    final updated = (await tasks.getTasks(categoryId: inbox.id)).single;
    expect(updated.id, original.id);
    expect(updated.title, 'Updated title');
    expect(updated.isCompleted, original.isCompleted);
    expect(updated.createdAt, original.createdAt);
    expect(updated.completedAt, original.completedAt);
    expect(updated.categoryId, original.categoryId);
    expect(widgetRefreshCount, 1);
  });

  testWidgets('rejects an empty task-title edit', (WidgetTester tester) async {
    await tasks.createTask('Keep title');
    await pumpKedis(tester);
    await openCategory(tester, 'Inbox');

    await tester.tap(find.text('Keep title'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byTooltip('Save changes'));
    await tester.pump();

    expect(find.text('Task title cannot be empty.'), findsOneWidget);
    expect(find.byType(EditingTaskItem), findsOneWidget);
    expect((await tasks.getTasks()).single.title, 'Keep title');
    expect(widgetRefreshCount, 0);
  });

  testWidgets('completes a task and undo restores its active state', (
    WidgetTester tester,
  ) async {
    await tasks.createTask('Accidental completion');
    await pumpKedis(tester);
    await openCategory(tester, 'Inbox');

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect((await tasks.getTasks()).single.isCompleted, isTrue);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    final restored = (await tasks.getTasks()).single;
    expect(restored.isCompleted, isFalse);
    expect(restored.completedAt, isNull);
    expect(widgetRefreshCount, 2);
  });

  testWidgets('deletes and restores a task with its category identity', (
    WidgetTester tester,
  ) async {
    final school = await categories.createCategory('School', 0xFF6750A4);
    final original = await tasks.createTask(
      'Restore me',
      categoryId: school.id,
    );
    await pumpKedis(tester);
    await openCategory(tester, 'School');

    await tester.tap(find.byTooltip('Delete Restore me'));
    await tester.pumpAndSettle();
    expect(await tasks.getTasks(categoryId: school.id), isEmpty);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    final restored = (await tasks.getTasks(categoryId: school.id)).single;
    expect(restored.id, original.id);
    expect(restored.categoryId, school.id);
    expect(restored.createdAt, original.createdAt);
    expect(widgetRefreshCount, 2);
  });

  testWidgets('moves a task to another category from the task row', (
    WidgetTester tester,
  ) async {
    final school = await categories.createCategory('School', 0xFF6750A4);
    final programming = await categories.createCategory(
      'Programming',
      0xFF006C4C,
    );
    final task = await tasks.createTask('Move me', categoryId: school.id);
    final completedAt = DateTime.utc(2026, 9, 16, 14);
    await tasks.setTaskCompletion(
      task.id,
      isCompleted: true,
      completedAt: completedAt,
    );
    await pumpKedis(tester);
    await openCategory(tester, 'School');

    await tester.tap(find.byTooltip('Move Move me'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Programming'));
    await tester.pumpAndSettle();

    expect(await tasks.getTasks(categoryId: school.id), isEmpty);
    final moved = (await tasks.getTasks(categoryId: programming.id)).single;
    expect(moved.id, task.id);
    expect(moved.isCompleted, isTrue);
    expect(moved.completedAt, completedAt);
    expect(widgetRefreshCount, 1);
  });

  testWidgets('creates, renames, and safely deletes a custom category', (
    WidgetTester tester,
  ) async {
    await pumpKedis(tester);

    await tester.tap(find.byTooltip('Add category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'School');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('School'), findsOneWidget);

    final school = (await categories.getCategories()).singleWhere(
      (category) => category.name == 'School',
    );
    await tasks.createTask('Keep task', categoryId: school.id);

    await tester.tap(find.byTooltip('Category actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Programming');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Programming'), findsOneWidget);

    await tester.tap(find.byTooltip('Category actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete category'));
    await tester.pumpAndSettle();
    expect(find.text('Its tasks will be moved to Inbox.'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Programming'), findsNothing);
    final inbox = await categories.getInbox();
    expect(
      (await tasks.getTasks(categoryId: inbox.id)).single.title,
      'Keep task',
    );
  });

  testWidgets('keeps active tasks before newest-first completed tasks', (
    WidgetTester tester,
  ) async {
    final oldest = await tasks.createTask('Oldest completed');
    final newer = await tasks.createTask('Newer completed');
    await tasks.createTask('Active');
    await tasks.setTaskCompletion(
      oldest.id,
      isCompleted: true,
      completedAt: DateTime.utc(2026, 9, 16, 10),
    );
    await tasks.setTaskCompletion(
      newer.id,
      isCompleted: true,
      completedAt: DateTime.utc(2026, 9, 16, 11),
    );
    await pumpKedis(tester);
    await openCategory(tester, 'Inbox');

    final activeY = tester.getTopLeft(find.text('Active')).dy;
    final completedLabelY = tester.getTopLeft(find.text('Completed')).dy;
    final newerY = tester.getTopLeft(find.text('Newer completed')).dy;
    final oldestY = tester.getTopLeft(find.text('Oldest completed')).dy;
    expect(activeY, lessThan(completedLabelY));
    expect(completedLabelY, lessThan(newerY));
    expect(newerY, lessThan(oldestY));
  });

  testWidgets('reloads category tasks when the app resumes', (
    WidgetTester tester,
  ) async {
    final task = await tasks.createTask('Changed from widget');
    await pumpKedis(tester);
    await openCategory(tester, 'Inbox');

    await tasks.toggleTask(task.id);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('changes and persists theme from settings', (
    WidgetTester tester,
  ) async {
    await pumpKedis(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(themePreferenceStore.savedThemeMode, ThemeMode.dark);
  });
}

class _FakeThemePreferenceStore extends ThemePreferenceStore {
  ThemeMode? savedThemeMode;

  @override
  Future<void> save(ThemeMode themeMode) async {
    savedThemeMode = themeMode;
  }
}
