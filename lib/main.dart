import 'dart:async';

import 'package:dewwit/models/task.dart';
import 'package:dewwit/repositories/task_repository.dart';
import 'package:dewwit/settings/settings_screen.dart';
import 'package:dewwit/settings/theme_controller.dart';
import 'package:dewwit/settings/theme_preference_store.dart';
import 'package:dewwit/services/dewwit_widget_updater.dart';
import 'package:dewwit/theme/dewwit_design.dart';
import 'package:dewwit/theme/dewwit_theme.dart';
import 'package:dewwit/widgets/dewwit_task_item.dart';
import 'package:dewwit/widgets/editable_task_item.dart';
import 'package:dewwit/widgets/empty_task_state.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferenceStore = ThemePreferenceStore();
  final initialThemeMode = await preferenceStore.load();

  runApp(
    DewwitApp(
      taskRepository: TaskRepository(),
      themeController: ThemeController(
        preferenceStore,
        initialThemeMode: initialThemeMode,
      ),
    ),
  );
  unawaited(DewwitWidgetUpdater.syncThemeMode(initialThemeMode));
}

class DewwitApp extends StatefulWidget {
  const DewwitApp({
    required this.taskRepository,
    required this.themeController,
    this.widgetRefresh = DewwitWidgetUpdater.refresh,
    super.key,
  });

  final TaskRepository taskRepository;
  final ThemeController themeController;
  final Future<void> Function() widgetRefresh;

  @override
  State<DewwitApp> createState() => _DewwitAppState();
}

class _DewwitAppState extends State<DewwitApp> {
  @override
  void initState() {
    super.initState();
    widget.themeController.addListener(_themeChanged);
  }

  @override
  void didUpdateWidget(DewwitApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeController != widget.themeController) {
      oldWidget.themeController.removeListener(_themeChanged);
      widget.themeController.addListener(_themeChanged);
    }
  }

  @override
  void dispose() {
    widget.themeController.removeListener(_themeChanged);
    super.dispose();
  }

  void _themeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dewwit',
      theme: DewwitTheme.light,
      darkTheme: DewwitTheme.dark,
      themeMode: widget.themeController.themeMode,
      home: DewwitHomePage(
        taskRepository: widget.taskRepository,
        themeController: widget.themeController,
        widgetRefresh: widget.widgetRefresh,
      ),
    );
  }
}

class DewwitHomePage extends StatefulWidget {
  const DewwitHomePage({
    required this.taskRepository,
    required this.themeController,
    required this.widgetRefresh,
    super.key,
  });

  final TaskRepository taskRepository;
  final ThemeController themeController;
  final Future<void> Function() widgetRefresh;

  @override
  State<DewwitHomePage> createState() => _DewwitHomePageState();
}

class _DewwitHomePageState extends State<DewwitHomePage>
    with WidgetsBindingObserver {
  List<Task> _tasks = const [];
  bool _isLoading = true;
  bool _hasLoadError = false;
  bool _isCreatingTask = false;
  bool _isFinishingDraft = false;
  final _draftController = TextEditingController();
  final _draftFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _draftFocusNode.addListener(_handleDraftFocusChange);
    _loadTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _draftFocusNode.removeListener(_handleDraftFocusChange);
    _draftController.dispose();
    _draftFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTasks();
    }
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

  void _startCreatingTask() {
    if (_isCreatingTask) {
      _draftFocusNode.requestFocus();
      return;
    }

    setState(() => _isCreatingTask = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isCreatingTask) {
        _draftFocusNode.requestFocus();
      }
    });
  }

  void _handleDraftFocusChange() {
    if (!_draftFocusNode.hasFocus && _isCreatingTask) {
      _finishDraft();
    }
  }

  Future<void> _finishDraft() async {
    if (!_isCreatingTask || _isFinishingDraft) return;

    final title = _draftController.text.trim();
    _isFinishingDraft = true;
    setState(() => _isCreatingTask = false);
    _draftController.clear();

    if (title.isNotEmpty) {
      await _runMutation(() async {
        await widget.taskRepository.createTask(title);
      });
    }

    _isFinishingDraft = false;
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
      await widget.widgetRefresh();
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
      appBar: AppBar(
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dewwit',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
            Text(
              'Your checklist',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: DewwitSpacing.small),
            child: IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) =>
                      SettingsScreen(themeController: widget.themeController),
                ),
              ),
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: _isCreatingTask
          ? null
          : TextFieldTapRegion(
              child: SizedBox(
                width: 72,
                height: 72,
                child: FloatingActionButton(
                  onPressed: _startCreatingTask,
                  tooltip: 'Add task',
                  child: const Icon(Icons.add, size: 32),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasLoadError) {
      return Center(
        child: FilledButton.tonalIcon(
          onPressed: _loadTasks,
          icon: const Icon(Icons.refresh),
          label: const Text('Could not load tasks. Try again'),
        ),
      );
    }

    if (_tasks.isEmpty && !_isCreatingTask) {
      return const EmptyTaskState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        DewwitSpacing.medium,
        DewwitSpacing.small,
        DewwitSpacing.medium,
        104,
      ),
      itemCount: _tasks.length + (_isCreatingTask ? 1 : 0),
      separatorBuilder: (context, index) =>
          const SizedBox(height: DewwitSpacing.small),
      itemBuilder: (context, index) {
        if (index == _tasks.length) {
          return EditableTaskItem(
            key: const ValueKey('task-draft-row'),
            controller: _draftController,
            focusNode: _draftFocusNode,
            onFinish: _finishDraft,
          );
        }

        final task = _tasks[index];
        return DewwitTaskItem(
          key: ValueKey(task.id),
          task: task,
          onToggle: () => _toggleTask(task),
          onDelete: () => _deleteTask(task),
        );
      },
    );
  }
}
