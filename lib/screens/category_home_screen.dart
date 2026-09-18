import 'package:kedis/models/task.dart';
import 'package:kedis/models/task_category.dart';
import 'package:kedis/repositories/category_repository.dart';
import 'package:kedis/repositories/task_repository.dart';
import 'package:kedis/screens/category_task_screen.dart';
import 'package:kedis/settings/home_layout_controller.dart';
import 'package:kedis/settings/home_layout_preference_store.dart';
import 'package:kedis/settings/settings_screen.dart';
import 'package:kedis/settings/theme_controller.dart';
import 'package:kedis/theme/kedis_design.dart';
import 'package:kedis/widgets/category_card.dart';
import 'package:kedis/widgets/category_editor_dialog.dart';
import 'package:flutter/material.dart';

class CategoryHomeScreen extends StatefulWidget {
  const CategoryHomeScreen({
    required this.categoryRepository,
    required this.taskRepository,
    required this.themeController,
    required this.homeLayoutController,
    required this.widgetRefresh,
    super.key,
  });

  final CategoryRepository categoryRepository;
  final TaskRepository taskRepository;
  final ThemeController themeController;
  final HomeLayoutController homeLayoutController;
  final Future<void> Function() widgetRefresh;

  @override
  State<CategoryHomeScreen> createState() => _CategoryHomeScreenState();
}

class _CategoryHomeScreenState extends State<CategoryHomeScreen>
    with WidgetsBindingObserver {
  static const _previewLimit = 3;
  static const _gridSpacing = KedisSpacing.small;
  static const _minimumGridCardWidth = 148.0;

  List<TaskCategory> _categories = const [];
  List<Task> _tasks = const [];
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
      final tasksFuture = widget.taskRepository.getTasks();
      final categories = await categoriesFuture;
      final tasks = await tasksFuture;
      if (!mounted) return;

      setState(() {
        _categories = categories;
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

  Future<void> _openCategory(TaskCategory category) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CategoryTaskScreen(
          category: category,
          categoryRepository: widget.categoryRepository,
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
    TaskCategory inbox;
    try {
      inbox = await widget.categoryRepository.getInbox();
    } on Object {
      if (mounted) _showMessage('Could not load categories.');
      return;
    }
    if (!mounted) return;

    var draftTitle = '';
    var selectedCategoryId = inbox.id;
    final result = await showDialog<_QuickCaptureResult>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          void submit(String rawTitle) {
            final normalizedTitle = rawTitle.trim();
            if (normalizedTitle.isEmpty) return;
            Navigator.of(dialogContext).pop(
              _QuickCaptureResult(
                title: normalizedTitle,
                categoryId: selectedCategoryId,
              ),
            );
          }

          return AlertDialog(
            title: const Text('Add task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  minLines: 1,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Task title'),
                  onChanged: (value) => draftTitle = value,
                  onSubmitted: submit,
                ),
                const SizedBox(height: KedisSpacing.medium),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Category'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      key: const ValueKey('quick-capture-category'),
                      value: selectedCategoryId,
                      isExpanded: true,
                      items: [
                        for (final category in _categories)
                          DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(
                              category.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (categoryId) {
                        if (categoryId == null) return;
                        setDialogState(
                          () => selectedCategoryId = categoryId,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => submit(draftTitle),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
    if (result == null || !mounted) return;

    try {
      await widget.taskRepository.createTask(
        result.title,
        categoryId: result.categoryId,
      );
      await widget.widgetRefresh();
      await _loadOverview();
    } on Object {
      if (!mounted) return;
      _showMessage('Could not create task.');
    }
  }

  Future<void> _createCategory() async {
    final result = await showCategoryEditorDialog(context);
    if (result == null || !mounted) return;

    try {
      await widget.categoryRepository.createCategory(
        result.name,
        result.colorValue,
      );
      await _loadOverview();
    } on StateError catch (error) {
      if (mounted) _showMessage(error.message.toString());
    } on Object {
      if (mounted) _showMessage('Could not create category.');
    }
  }

  Future<void> _editCategory(TaskCategory category) async {
    final result = await showCategoryEditorDialog(context, category: category);
    if (result == null || !mounted) return;

    try {
      if (result.name != category.name) {
        await widget.categoryRepository.renameCategory(
          category.id,
          result.name,
        );
      }
      if (result.colorValue != category.colorValue) {
        await widget.categoryRepository.updateCategoryColor(
          category.id,
          result.colorValue,
        );
      }
      await _loadOverview();
    } on StateError catch (error) {
      if (mounted) _showMessage(error.message.toString());
    } on Object {
      if (mounted) _showMessage('Could not update category.');
    }
  }

  Future<void> _deleteCategory(TaskCategory category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${category.name}?'),
        content: const Text('Its tasks will be moved to Inbox.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    try {
      await widget.categoryRepository.deleteCategory(category.id);
      await widget.widgetRefresh();
      await _loadOverview();
    } on StateError catch (error) {
      if (mounted) _showMessage(error.message.toString());
    } on Object {
      if (mounted) _showMessage('Could not delete category.');
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SettingsScreen(
          themeController: widget.themeController,
          homeLayoutController: widget.homeLayoutController,
          taskRepository: widget.taskRepository,
          widgetRefresh: widget.widgetRefresh,
        ),
      ),
    );
    if (mounted) {
      await _loadOverview();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          IconButton(
            onPressed: _createCategory,
            tooltip: 'Add category',
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: KedisSpacing.small),
            child: IconButton(
              onPressed: _openSettings,
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
          tooltip: 'Add task',
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

    return ListenableBuilder(
      listenable: widget.homeLayoutController,
      builder: (context, _) {
        final tasksByCategory = <int, List<Task>>{};
        for (final task in _tasks) {
          tasksByCategory.putIfAbsent(task.categoryId, () => []).add(task);
        }

        return switch (widget.homeLayoutController.layoutMode) {
          HomeLayoutMode.grid => _buildGrid(tasksByCategory),
          HomeLayoutMode.list => _buildList(tasksByCategory),
        };
      },
    );
  }

  Widget _buildGrid(Map<int, List<Task>> tasksByCategory) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = KedisSpacing.medium * 2;
        final contentWidth = constraints.maxWidth - horizontalPadding;
        final twoColumns =
            contentWidth >= (_minimumGridCardWidth * 2) + _gridSpacing;
        final cardWidth = twoColumns
            ? (contentWidth - _gridSpacing) / 2
            : contentWidth;

        return SingleChildScrollView(
          key: const ValueKey('category-home-grid'),
          padding: const EdgeInsets.fromLTRB(
            KedisSpacing.medium,
            KedisSpacing.small,
            KedisSpacing.medium,
            104,
          ),
          child: Wrap(
            spacing: _gridSpacing,
            runSpacing: KedisSpacing.medium,
            children: [
              for (final category in _categories)
                SizedBox(
                  width: cardWidth,
                  child: _buildCategoryCard(
                    category,
                    tasksByCategory[category.id] ?? const [],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(Map<int, List<Task>> tasksByCategory) {
    return ListView.separated(
      key: const ValueKey('category-home-list'),
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
        return _buildCategoryCard(
          category,
          tasksByCategory[category.id] ?? const [],
        );
      },
    );
  }

  Widget _buildCategoryCard(TaskCategory category, List<Task> categoryTasks) {
    final activeTasks = categoryTasks
        .where((task) => !task.isCompleted)
        .toList(growable: false);
    final previewTasks = activeTasks
        .take(_previewLimit)
        .toList(growable: false);

    return CategoryCard(
      key: ValueKey('category-card-${category.id}'),
      category: category,
      activeCount: activeTasks.length,
      totalCount: categoryTasks.length,
      previewTasks: previewTasks,
      onTap: () => _openCategory(category),
      onEdit: category.isSystem ? null : () => _editCategory(category),
      onDelete: category.isSystem ? null : () => _deleteCategory(category),
    );
  }
}


class _QuickCaptureResult {
  const _QuickCaptureResult({
    required this.title,
    required this.categoryId,
  });

  final String title;
  final int categoryId;
}
