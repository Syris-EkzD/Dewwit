import 'package:dewwit/main.dart';
import 'package:dewwit/models/task.dart';
import 'package:dewwit/repositories/task_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late _FakeTaskRepository repository;

  setUp(() {
    repository = _FakeTaskRepository();
  });

  Future<void> pumpDewwit(WidgetTester tester) async {
    await tester.pumpWidget(DewwitApp(taskRepository: repository));
    await tester.pumpAndSettle();
  }

  testWidgets('loads persisted tasks', (WidgetTester tester) async {
    await repository.createTask('Buy groceries');

    await pumpDewwit(tester);

    expect(find.text('Dewwit'), findsOneWidget);
    expect(find.text('Buy groceries'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  testWidgets('creates a task and refreshes the checklist', (
    WidgetTester tester,
  ) async {
    await pumpDewwit(tester);
    expect(find.text('No tasks yet.'), findsOneWidget);

    await tester.tap(find.byTooltip('Add task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Finish activity');
    await tester.pump();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Finish activity'), findsOneWidget);
    expect((await repository.getTasks()).single.title, 'Finish activity');
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
    expect(find.text('No tasks yet.'), findsOneWidget);
    expect(await repository.getTasks(), isEmpty);
  });
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
