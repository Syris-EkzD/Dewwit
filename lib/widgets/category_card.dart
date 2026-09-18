import 'package:kedis/models/task.dart';
import 'package:kedis/models/task_category.dart';
import 'package:kedis/theme/kedis_design.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    required this.activeCount,
    required this.totalCount,
    required this.previewTasks,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final TaskCategory category;
  final int activeCount;
  final int totalCount;
  final List<Task> previewTasks;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = Color(category.colorValue);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hiddenCount = activeCount - previewTasks.length;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: accent, width: 4)),
          ),
          padding: const EdgeInsets.fromLTRB(
            KedisSpacing.medium,
            KedisSpacing.medium,
            KedisSpacing.small,
            KedisSpacing.medium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onEdit != null && onDelete != null)
                    PopupMenuButton<_CategoryCardAction>(
                      tooltip: 'Category actions',
                      onSelected: (action) {
                        switch (action) {
                          case _CategoryCardAction.edit:
                            onEdit?.call();
                            break;
                          case _CategoryCardAction.delete:
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: _CategoryCardAction.edit,
                          child: Text('Edit category'),
                        ),
                        PopupMenuItem(
                          value: _CategoryCardAction.delete,
                          child: Text('Delete category'),
                        ),
                      ],
                    )
                  else
                    const SizedBox(width: KedisSpacing.small),
                ],
              ),
              const SizedBox(height: KedisSpacing.xSmall),
              Wrap(
                spacing: KedisSpacing.xSmall,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '$activeCount active',
                    style: textTheme.bodySmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '· $totalCount total',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (previewTasks.isEmpty) ...[
                const SizedBox(height: KedisSpacing.small),
                Text(
                  'No active tasks',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else ...[
                const SizedBox(height: KedisSpacing.small),
                ...previewTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(top: KedisSpacing.xSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: KedisSpacing.small),
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hiddenCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: KedisSpacing.small),
                    child: Text(
                      '+$hiddenCount more',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

enum _CategoryCardAction { edit, delete }
