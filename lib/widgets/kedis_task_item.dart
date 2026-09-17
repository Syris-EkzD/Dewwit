import 'package:kedis/models/task.dart';
import 'package:kedis/theme/kedis_design.dart';
import 'package:flutter/material.dart';

class KedisTaskItem extends StatelessWidget {
  const KedisTaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
    this.onMove,
    super.key,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onMove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(KedisRadii.medium),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        horizontalTitleGap: 8,
        minLeadingWidth: 24,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KedisSpacing.xSmall,
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onMove != null)
              IconButton(
                onPressed: onMove,
                tooltip: 'Move ${task.title}',
                icon: const Icon(Icons.swap_horiz),
                color: colorScheme.onSurfaceVariant,
              ),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Delete ${task.title}',
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
