import 'package:dewwit/settings/theme_controller.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SettingsSection(
            title: 'Appearance',
            children: [
              ListenableBuilder(
                listenable: themeController,
                builder: (context, _) => SettingsItem(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  value: _themeModeLabel(themeController.themeMode),
                  onTap: () => _showThemeDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final selectedMode = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Theme'),
        children: ThemeMode.values.map((mode) {
          final isSelected = mode == themeController.themeMode;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, mode),
            child: Row(
              children: [
                Expanded(child: Text(_themeModeLabel(mode))),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (selectedMode != null) {
      await themeController.setThemeMode(selectedMode);
    }
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

String _themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };
}
