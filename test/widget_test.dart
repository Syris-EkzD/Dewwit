import 'package:dewwit/main.dart';
import 'package:dewwit/models/task.dart';
import 'package:dewwit/repositories/task_repository.dart';
import 'package:dewwit/settings/theme_controller.dart';
import 'package:dewwit/settings/theme_preference_store.dart';
import 'package:dewwit/widgets/editable_task_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late _FakeTaskRepository repository;
  late int widgetRefreshCount;
  late _FakeThemePreferenceStore themePreferenceStore;

  setUp(() {
    repository = _FakeTaskRepository();
    widgetRefreshCount = 0;
    themePreferenceStore = _FakeThemePreferenceStore();
  });

  Future<void> pumpDewwit(WidgetTester tester) async {
    await tester.pumpWidget(
      DewwitApp(
        taskRepository: repository,
        themeController: ThemeController(themePreferenceStore),
        widgetRefresh: () async {
          widgetRefreshCount += 1;
        },
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loads persisted tasks', (WidgetTester tester) async {
    await repository.createTask('Buy groceries');

    await pumpDewwit(tester);

    expect(find.text('Dewwit'), findsOneWidget);
    expect(find.text('Buy groceries'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  testWidgets('opens one focused inline draft and hides the Add FAB', (
    WidgetTester tester,
  ) async {
    await pumpDewwit(tester);
    expect(find.text('No tasks yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    expect(find.byType(EditableTaskItem), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('No tasks yet'), findsNothing);
    expect(find.byTooltip('Add task'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus,
      isTrue,
    );

    await tester.enterText(find.byType(TextField), 'Draft stays');

    expect(find.byType(EditableTaskItem), findsOneWidget);
    expect(find.text('Draft stays'), findsOneWidget);
    expect(await repository.getTasks(), isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus,
      isTrue,
    );
  });

  testWidgets('submits a valid inline draft and refreshes the checklist', (
    WidgetTester tester,
  ) async {
    await pumpDewwit(tester);
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  Finish activity  ');
    await tester.pump();
    await tester.tap(find.byTooltip('Save task'));
    await tester.pumpAndSettle();

    expect(find.text('Finish activity'), findsOneWidget);
    expect(find.byType(EditableTaskItem), findsNothing);
    expect((await repository.getTasks()).single.title, 'Finish activity');
    expect(widgetRefreshCount, 1);
  });

  testWidgets('multiline draft grows to keep its text visible', (
    WidgetTester tester,
  ) async {
    await pumpDewwit(tester);
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    final input = find.byKey(const ValueKey('task-draft-input'));
    final initialHeight = tester.getSize(input).height;
    final textField = tester.widget<TextField>(input);
    expect(textField.minLines, 1);
    expect(textField.maxLines, isNull);

    await tester.enterText(
      input,
      'First part of a long task\nSecond part\nThird part',
    );
    await tester.pump();

    expect(tester.getSize(input).height, greaterThan(initialHeight));
  });

  testWidgets('discards an empty inline draft without persistence', (
    WidgetTester tester,
  ) async {
    await pumpDewwit(tester);
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Discard draft'));
    await tester.pumpAndSettle();

    expect(find.byType(EditableTaskItem), findsNothing);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(await repository.getTasks(), isEmpty);
    expect(widgetRefreshCount, 0);
  });

  testWidgets('toggles and deletes a task', (WidgetTester tester) async {
    await repository.createTask('Review networking');
    await pumpDewwit(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect((await repository.getTasks()).single.isCompleted, isTrue);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Review networking'), findsNothing);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(await repository.getTasks(), isEmpty);
    expect(widgetRefreshCount, 2);
  });

  testWidgets('undoes deletion of an active task with its original identity', (
    WidgetTester tester,
  ) async {
    final original = await repository.createTask('Restore active');
    await pumpDewwit(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Task deleted'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);
    expect(find.text('Restore active'), findsNothing);
    expect(await repository.getTasks(), isEmpty);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    final restored = (await repository.getTasks()).single;
    expect(restored.id, original.id);
    expect(restored.createdAt, original.createdAt);
    expect(restored.isCompleted, isFalse);
    expect(restored.completedAt, isNull);
    expect(find.text('Restore active'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
    expect(widgetRefreshCount, 2);
  });

  testWidgets('restores a completed deletion in its original ordering', (
    WidgetTester tester,
  ) async {
    final older = await repository.createTask('Older completed');
    final newest = await repository.createTask('Newest completed');
    final olderCompletedAt = DateTime.utc(2026, 9, 3, 8);
    final newestCompletedAt = DateTime.utc(2026, 9, 3, 9);
    await repository.setTaskCompletion(
      older.id,
      isCompleted: true,
      completedAt: olderCompletedAt,
    );
    final original = await repository.setTaskCompletion(
      newest.id,
      isCompleted: true,
      completedAt: newestCompletedAt,
    );
    await pumpDewwit(tester);

    await tester.tap(find.byTooltip('Delete Newest completed'));
    await tester.pumpAndSettle();
    expect(find.text('Newest completed'), findsNothing);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    final tasks = await repository.getTasks();
    final restored = tasks.first;
    expect(restored.id, original!.id);
    expect(restored.createdAt, original.createdAt);
    expect(restored.completedAt, newestCompletedAt);
    expect(restored.isCompleted, isTrue);
    expect(find.text('Completed'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Newest completed')).dy,
      lessThan(tester.getTopLeft(find.text('Older completed')).dy),
    );
    expect(widgetRefreshCount, 2);
  });

  testWidgets('leaves a task deleted after the Undo Snackbar expires', (
    WidgetTester tester,
  ) async {
    await repository.createTask('Delete permanently');
    await pumpDewwit(tester);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('UNDO'), findsNothing);
    expect(find.text('Delete permanently'), findsNothing);
    expect(await repository.getTasks(), isEmpty);
    expect(widgetRefreshCount, 1);
  });

  testWidgets('undoes completion and returns the task to active', (
    WidgetTester tester,
  ) async {
    await repository.createTask('Accidental completion');
    await pumpDewwit(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(find.text('Task completed'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect((await repository.getTasks()).single.completedAt, isNotNull);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    final restored = (await repository.getTasks()).single;
    expect(restored.isCompleted, isFalse);
    expect(restored.completedAt, isNull);
    expect(find.text('Completed'), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(widgetRefreshCount, 2);
  });

  testWidgets('undoes uncompletion with the original completion timestamp', (
    WidgetTester tester,
  ) async {
    final task = await repository.createTask('Restore completion');
    final completed = await repository.toggleTask(task.id);
    final originalCompletedAt = completed!.completedAt;
    await pumpDewwit(tester);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(find.text('Task marked incomplete'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    final restored = (await repository.getTasks()).single;
    expect(restored.isCompleted, isTrue);
    expect(restored.completedAt, originalCompletedAt);
    expect(find.text('Completed'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(widgetRefreshCount, 2);
  });

  testWidgets('reloads tasks when the app resumes', (
    WidgetTester tester,
  ) async {
    final task = await repository.createTask('Changed from widget');
    await pumpDewwit(tester);

    await repository.toggleTask(task.id);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('shows active tasks before a newest-first Completed section', (
    WidgetTester tester,
  ) async {
    final oldest = await repository.createTask('Oldest');
    final middle = await repository.createTask('Middle');
    await repository.createTask('Newest active');
    await repository.toggleTask(oldest.id);
    await tester.pump(const Duration(milliseconds: 2));
    await repository.toggleTask(middle.id);

    await pumpDewwit(tester);

    expect(find.text('Completed'), findsOneWidget);
    final activeY = tester.getTopLeft(find.text('Newest active')).dy;
    final labelY = tester.getTopLeft(find.text('Completed')).dy;
    final recentY = tester.getTopLeft(find.text('Middle')).dy;
    final olderY = tester.getTopLeft(find.text('Oldest')).dy;
    expect(activeY, lessThan(labelY));
    expect(labelY, lessThan(recentY));
    expect(recentY, lessThan(olderY));
  });

  testWidgets('changes and persists theme from settings', (
    WidgetTester tester,
  ) async {
    await pumpDewwit(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(themePreferenceStore.savedThemeMode, ThemeMode.dark);
    expect(find.text('Dark'), findsOneWidget);
  });
}

class _FakeThemePreferenceStore extends ThemePreferenceStore {
  ThemeMode? savedThemeMode;

  @override
  Future<void> save(ThemeMode themeMode) async {
    savedThemeMode = themeMode;
  }
}

class _FakeTaskRepository extends TaskRepository {
  _FakeTaskRepository()
    : super.atPath(inMemoryDatabasePath, factory: databaseFactoryFfi);

  final List<Task> _tasks = [];
  var _nextId = 1;

  @override
  Future<Task> createTask(String title) async {
    final task = Task(
      id: _nextId++,
      title: title.trim(),
      isCompleted: false,
      createdAt: DateTime.now().toUtc(),
      completedAt: null,
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<List<Task>> getTasks() async {
    final tasks = List<Task>.of(_tasks)
      ..sort((first, second) {
        if (first.isCompleted != second.isCompleted) {
          return first.isCompleted ? 1 : -1;
        }
        if (!first.isCompleted) {
          return first.createdAt.compareTo(second.createdAt);
        }
        final firstCompletedAt = first.completedAt;
        final secondCompletedAt = second.completedAt;
        if (firstCompletedAt == null || secondCompletedAt == null) {
          if (firstCompletedAt == null && secondCompletedAt != null) return 1;
          if (firstCompletedAt != null && secondCompletedAt == null) return -1;
          return first.createdAt.compareTo(second.createdAt);
        }
        return secondCompletedAt.compareTo(firstCompletedAt);
      });
    return List.unmodifiable(tasks);
  }

  @override
  Future<Task?> toggleTask(int id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return null;

    final current = _tasks[index];
    final updated = Task(
      id: current.id,
      title: current.title,
      isCompleted: !current.isCompleted,
      createdAt: current.createdAt,
      completedAt: current.isCompleted ? null : DateTime.now().toUtc(),
    );
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<Task?> setTaskCompletion(
    int id, {
    required bool isCompleted,
    required DateTime? completedAt,
  }) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return null;

    final current = _tasks[index];
    final updated = Task(
      id: current.id,
      title: current.title,
      isCompleted: isCompleted,
      createdAt: current.createdAt,
      completedAt: isCompleted ? completedAt : null,
    );
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<bool> deleteTask(int id) async {
    final originalLength = _tasks.length;
    _tasks.removeWhere((task) => task.id == id);
    return _tasks.length != originalLength;
  }

  @override
  Future<Task> restoreTask(Task task) async {
    _tasks.add(task);
    return task;
  }
}
