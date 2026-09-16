import 'package:kedis/models/task.dart';
import 'package:kedis/models/task_category.dart';
import 'package:kedis/theme/kedis_design.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    required this.activeCount,
    required this.previewTasks,
    required this.onTap,
    super.key,
  });

  final TaskCategory category;
  final int activeCount;
  final List<Task> previewTasks;
  final VoidCallback onTap;

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
            KedisSpacing.medium,
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
                  const SizedBox(width: KedisSpacing.small),
                  Text(
                    '$activeCount',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
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
