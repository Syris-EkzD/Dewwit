import 'dart:async';

import 'package:kedis/repositories/category_repository.dart';
import 'package:kedis/repositories/kedis_database.dart';
import 'package:kedis/repositories/task_repository.dart';
import 'package:kedis/screens/category_home_screen.dart';
import 'package:kedis/settings/theme_controller.dart';
import 'package:kedis/settings/theme_preference_store.dart';
import 'package:kedis/services/kedis_widget_updater.dart';
import 'package:kedis/theme/kedis_theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferenceStore = ThemePreferenceStore();
  final initialThemeMode = await preferenceStore.load();
  final database = KedisDatabase();

  runApp(
    KedisApp(
      taskRepository: TaskRepository.withDatabase(database),
      categoryRepository: CategoryRepository.withDatabase(database),
      themeController: ThemeController(
        preferenceStore,
        initialThemeMode: initialThemeMode,
      ),
    ),
  );
  unawaited(KedisWidgetUpdater.syncThemeMode(initialThemeMode));
}

class KedisApp extends StatefulWidget {
  const KedisApp({
    required this.taskRepository,
    required this.categoryRepository,
    required this.themeController,
    this.widgetRefresh = KedisWidgetUpdater.refresh,
    super.key,
  });

  final TaskRepository taskRepository;
  final CategoryRepository categoryRepository;
  final ThemeController themeController;
  final Future<void> Function() widgetRefresh;

  @override
  State<KedisApp> createState() => _KedisAppState();
}

class _KedisAppState extends State<KedisApp> {
  @override
  void initState() {
    super.initState();
    widget.themeController.addListener(_themeChanged);
  }

  @override
  void didUpdateWidget(KedisApp oldWidget) {
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
      title: 'Kedis',
      theme: KedisTheme.light,
      darkTheme: KedisTheme.dark,
      themeMode: widget.themeController.themeMode,
      home: CategoryHomeScreen(
        categoryRepository: widget.categoryRepository,
        taskRepository: widget.taskRepository,
        themeController: widget.themeController,
        widgetRefresh: widget.widgetRefresh,
      ),
    );
  }
}
