import 'package:dewwit/settings/theme_controller.dart';
import 'package:flutter/material.dart';

const _screenHorizontalPadding = 16.0;
const _screenTopPadding = 8.0;
const _screenBottomPadding = 24.0;
const _sectionTopSpacing = 16.0;
const _sectionTitleHorizontalPadding = 4.0;
const _sectionTitleBottomSpacing = 8.0;
const _itemHorizontalPadding = 16.0;
const _itemVerticalPadding = 14.0;
const _itemIconSize = 40.0;
const _itemIconRadius = 12.0;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.themeController, super.key});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            _screenHorizontalPadding,
            _screenTopPadding,
            _screenHorizontalPadding,
            _screenBottomPadding,
          ),
          children: [
            SettingsSection(
              title: 'Appearance',
              children: [
                ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) => SettingsItem(
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    description: 'Choose how Dewwit looks',
                    value: _themeModeLabel(themeController.themeMode),
                    onTap: () => _showThemeDialog(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final selectedMode = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose theme'),
        content: RadioGroup<ThemeMode>(
          groupValue: themeController.themeMode,
          onChanged: (mode) => Navigator.pop(context, mode),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values
                .map(
                  (mode) => RadioListTile<ThemeMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_themeModeLabel(mode)),
                    subtitle: Text(_themeModeDescription(mode)),
                    value: mode,
                  ),
                )
                .toList(),
          ),
        ),
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
      padding: const EdgeInsets.only(top: _sectionTopSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: _sectionTitleHorizontalPadding,
              right: _sectionTitleHorizontalPadding,
              bottom: _sectionTitleBottomSpacing,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    required this.icon,
    required this.title,
    this.description,
    required this.value,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _itemHorizontalPadding,
        vertical: _itemVerticalPadding,
      ),
      leading: Container(
        width: _itemIconSize,
        height: _itemIconSize,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(_itemIconRadius),
        ),
        child: Icon(icon, color: colorScheme.onSecondaryContainer),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: description == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colorScheme.primary),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
      onTap: onTap,
    );
  }
}

String _themeModeDescription(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'Match your device appearance',
    ThemeMode.light => 'Always use light appearance',
    ThemeMode.dark => 'Always use dark appearance',
  };
}

String _themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };
}
