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

  testWidgets('opens one focused inline draft without a dialog', (
    WidgetTester tester,
  ) async {
    await pumpDewwit(tester);
    expect(find.text('No tasks yet'), findsOneWidget);

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

    expect(find.byType(EditableTaskItem), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('No tasks yet'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).focusNode?.hasFocus,
      isTrue,
    );

    await tester.enterText(find.byType(TextField), 'Draft stays');
    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();

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
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<List<Task>> getTasks() async => List.unmodifiable(_tasks);

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
}
