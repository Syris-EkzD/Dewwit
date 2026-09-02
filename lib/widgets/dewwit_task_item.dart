import 'package:dewwit/models/task.dart';
import 'package:dewwit/theme/dewwit_design.dart';
import 'package:flutter/material.dart';

class DewwitTaskItem extends StatelessWidget {
  const DewwitTaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(DewwitRadii.medium),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        horizontalTitleGap: 8,
        minLeadingWidth: 24,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DewwitSpacing.xSmall,
        ),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Text(
              task.title,
              softWrap: true,
              maxLines: null,
              style: textTheme.bodyLarge?.copyWith(
                color: task.isCompleted
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurface,
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        trailing: IconButton(
          onPressed: onDelete,
          tooltip: 'Delete ${task.title}',
          icon: const Icon(Icons.delete_outline),
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
