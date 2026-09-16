import 'package:kedis/models/task.dart';
import 'package:kedis/models/task_category.dart';
import 'package:kedis/repositories/category_repository.dart';
import 'package:kedis/repositories/task_repository.dart';
import 'package:kedis/screens/category_task_screen.dart';
import 'package:kedis/settings/settings_screen.dart';
import 'package:kedis/settings/theme_controller.dart';
import 'package:kedis/theme/kedis_design.dart';
import 'package:kedis/widgets/category_card.dart';
import 'package:flutter/material.dart';

class CategoryHomeScreen extends StatefulWidget {
  const CategoryHomeScreen({
    required this.categoryRepository,
    required this.taskRepository,
    required this.themeController,
    required this.widgetRefresh,
    super.key,
  });

  final CategoryRepository categoryRepository;
  final TaskRepository taskRepository;
  final ThemeController themeController;
  final Future<void> Function() widgetRefresh;

  @override
  State<CategoryHomeScreen> createState() => _CategoryHomeScreenState();
}

class _CategoryHomeScreenState extends State<CategoryHomeScreen>
    with WidgetsBindingObserver {
  static const _previewLimit = 3;

  List<TaskCategory> _categories = const [];
  List<Task> _activeTasks = const [];
  bool _isLoading = true;
  bool _hasLoadError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadOverview();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadOverview();
    }
  }

  Future<void> _loadOverview() async {
    try {
      final categoriesFuture = widget.categoryRepository.getCategories();
      final tasksFuture = widget.taskRepository.getActiveTasks();
      final categories = await categoriesFuture;
      final activeTasks = await tasksFuture;
      if (!mounted) return;

      setState(() {
        _categories = categories;
        _activeTasks = activeTasks;
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

  Future<void> _openCategory(TaskCategory category) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CategoryTaskScreen(
          category: category,
          taskRepository: widget.taskRepository,
          widgetRefresh: widget.widgetRefresh,
        ),
      ),
    );
    if (mounted) {
      await _loadOverview();
    }
  }

  Future<void> _quickCapture() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add to Inbox'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 1,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Task title'),
          onSubmitted: (value) {
            final normalized = value.trim();
            if (normalized.isNotEmpty) {
              Navigator.of(context).pop(normalized);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final normalized = controller.text.trim();
              if (normalized.isNotEmpty) {
                Navigator.of(context).pop(normalized);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || !mounted) return;

    try {
      await widget.taskRepository.createTask(title);
      await widget.widgetRefresh();
      await _loadOverview();
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not create task.')));
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
              'Kedis',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Your categories',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: KedisSpacing.small),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8, bottom: 30),
        child: FloatingActionButton(
          onPressed: _quickCapture,
          tooltip: 'Add task to Inbox',
          child: const Icon(Icons.add, size: 26),
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
          onPressed: _loadOverview,
          icon: const Icon(Icons.refresh),
          label: const Text('Could not load categories. Try again'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        KedisSpacing.medium,
        KedisSpacing.small,
        KedisSpacing.medium,
        104,
      ),
      itemCount: _categories.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: KedisSpacing.medium),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final categoryTasks = _activeTasks
            .where((task) => task.categoryId == category.id)
            .toList(growable: false);
        final previewTasks = categoryTasks
            .take(_previewLimit)
            .toList(growable: false);

        return CategoryCard(
          key: ValueKey('category-card-${category.id}'),
          category: category,
          activeCount: categoryTasks.length,
          previewTasks: previewTasks,
          onTap: () => _openCategory(category),
        );
      },
    );
  }
}
