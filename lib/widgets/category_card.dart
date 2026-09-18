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
    this.isGridLayout = false,
    super.key,
  });

  static const gridHeight = 312.0;
  static const gridTitleHeight = 120.0;
  static const gridTitleMaxLines = 5;
  static const _gridCountHeight = 20.0;

  final TaskCategory category;
  final int activeCount;
  final int totalCount;
  final List<Task> previewTasks;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isGridLayout;

  @override
  Widget build(BuildContext context) {
    final accent = Color(category.colorValue);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hiddenCount = activeCount - previewTasks.length;
    final titleRow = _buildTitleRow(
      textTheme,
      maxLines: isGridLayout ? gridTitleMaxLines : 1,
      alignToTop: isGridLayout,
    );
    final counts = _buildCounts(textTheme, colorScheme, accent);

    final card = Card(
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
              if (isGridLayout)
                SizedBox(height: gridTitleHeight, child: titleRow)
              else
                titleRow,
              const SizedBox(height: KedisSpacing.xSmall),
              if (isGridLayout)
                SizedBox(
                  height: _gridCountHeight,
                  child: Align(alignment: Alignment.centerLeft, child: counts),
                )
              else
                counts,
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

    if (!isGridLayout) {
      return card;
    }
    return SizedBox(height: gridHeight, child: card);
  }

  Widget _buildTitleRow(
    TextTheme textTheme, {
    required int maxLines,
    required bool alignToTop,
  }) {
    return Row(
      crossAxisAlignment: alignToTop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            category.name,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
    );
  }

  Widget _buildCounts(
    TextTheme textTheme,
    ColorScheme colorScheme,
    Color accent,
  ) {
    return Wrap(
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
    );
  }
}

enum _CategoryCardAction { edit, delete }
