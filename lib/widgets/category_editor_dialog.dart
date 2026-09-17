import 'package:kedis/models/task_category.dart';
import 'package:kedis/theme/kedis_design.dart';
import 'package:flutter/material.dart';

const categoryColorPalette = <int>[
  0xFF426A5A,
  0xFF6750A4,
  0xFF006C4C,
  0xFF00658A,
  0xFF3F51B5,
  0xFF8C5000,
  0xFFB3261E,
  0xFF7D5260,
];

class CategoryEditorResult {
  const CategoryEditorResult({required this.name, required this.colorValue});

  final String name;
  final int colorValue;
}

Future<CategoryEditorResult?> showCategoryEditorDialog(
  BuildContext context, {
  TaskCategory? category,
}) async {
  var draftName = category?.name ?? '';
  var selectedColor = category?.colorValue ?? categoryColorPalette.first;
  var showNameError = false;

  final result = await showDialog<CategoryEditorResult>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(category == null ? 'Create category' : 'Edit category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: draftName,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: showNameError ? 'Enter a category name.' : null,
              ),
              onChanged: (value) => draftName = value,
              onFieldSubmitted: (value) {
                final name = value.trim();
                if (name.isEmpty) {
                  setDialogState(() => showNameError = true);
                  return;
                }
                Navigator.of(dialogContext).pop(
                  CategoryEditorResult(name: name, colorValue: selectedColor),
                );
              },
            ),
            const SizedBox(height: KedisSpacing.medium),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: KedisSpacing.small),
            Wrap(
              spacing: KedisSpacing.small,
              runSpacing: KedisSpacing.small,
              children: [
                for (final colorValue in categoryColorPalette)
                  _CategoryColorChoice(
                    colorValue: colorValue,
                    selected: selectedColor == colorValue,
                    onTap: () =>
                        setDialogState(() => selectedColor = colorValue),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = draftName.trim();
              if (name.isEmpty) {
                setDialogState(() => showNameError = true);
                return;
              }
              Navigator.of(dialogContext).pop(
                CategoryEditorResult(name: name, colorValue: selectedColor),
              );
            },
            child: Text(category == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    ),
  );

  return result;
}

class _CategoryColorChoice extends StatelessWidget {
  const _CategoryColorChoice({
    required this.colorValue,
    required this.selected,
    required this.onTap,
  });

  final int colorValue;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    final outline = Theme.of(context).colorScheme.onSurface;

    return Tooltip(
      message: selected ? 'Selected color' : 'Choose color',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected ? Border.all(color: outline, width: 3) : null,
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  size: 20,
                  color:
                      ThemeData.estimateBrightnessForColor(color) ==
                          Brightness.dark
                      ? Colors.white
                      : Colors.black,
                )
              : null,
        ),
      ),
    );
  }
}
