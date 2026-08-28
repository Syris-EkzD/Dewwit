import 'package:dewwit/models/task.dart';
import 'package:dewwit/repositories/task_repository.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DewwitApp(taskRepository: TaskRepository()));
}

class DewwitApp extends StatelessWidget {
  const DewwitApp({required this.taskRepository, super.key});

  final TaskRepository taskRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dewwit',
      home: DewwitHomePage(taskRepository: taskRepository),
    );
  }
}

class DewwitHomePage extends StatefulWidget {
  const DewwitHomePage({required this.taskRepository, super.key});

  final TaskRepository taskRepository;

  @override
  State<DewwitHomePage> createState() => _DewwitHomePageState();
}

class _DewwitHomePageState extends State<DewwitHomePage> {
  List<Task> _tasks = const [];
  bool _isLoading = true;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await widget.taskRepository.getTasks();
      if (!mounted) return;

      setState(() {
        _tasks = tasks;
        _isLoading = false;
        _hasLoadError = false;
      });
    } on Object {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasLoadError = true;
      });
    }
  }

  Future<void> _createTask() async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const _CreateTaskDialog(),
    );

    if (title == null) return;
    await _runMutation(() async {
      await widget.taskRepository.createTask(title);
    });
  }

  Future<void> _toggleTask(Task task) async {
    await _runMutation(() async {
      await widget.taskRepository.toggleTask(task.id);
    });
  }

  Future<void> _deleteTask(Task task) async {
    await _runMutation(() async {
      await widget.taskRepository.deleteTask(task.id);
    });
  }

  Future<void> _runMutation(Future<void> Function() mutation) async {
    try {
      await mutation();
      await _loadTasks();
    } on Object {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not update tasks.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dewwit')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasLoadError) {
      return Center(
        child: TextButton(
          onPressed: _loadTasks,
          child: const Text('Could not load tasks. Tap to retry.'),
        ),
      );
    }

    if (_tasks.isEmpty) {
      return const Center(child: Text('No tasks yet.'));
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return ListTile(
          key: ValueKey(task.id),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => _toggleTask(task),
          ),
          title: Text(
            task.title,
            style: task.isCompleted
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          trailing: IconButton(
            onPressed: () => _deleteTask(task),
            tooltip: 'Delete ${task.title}',
            icon: const Icon(Icons.delete_outline),
          ),
        );
      },
    );
  }
}

class _CreateTaskDialog extends StatefulWidget {
  const _CreateTaskDialog();

  @override
  State<_CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<_CreateTaskDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _controller.text.trim();

    return AlertDialog(
      title: const Text('New task'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Task title'),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: title.isEmpty ? null : () => Navigator.pop(context, title),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
