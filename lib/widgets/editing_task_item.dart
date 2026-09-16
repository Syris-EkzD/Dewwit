import 'package:kedis/models/task.dart';
import 'package:kedis/theme/kedis_design.dart';
import 'package:flutter/material.dart';

class EditingTaskItem extends StatelessWidget {
  const EditingTaskItem({
    required this.task,
    required this.controller,
    required this.focusNode,
    required this.onSave,
    required this.onCancel,
    super.key,
  });

  final Task task;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primaryContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(KedisRadii.medium),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.only(
          left: KedisSpacing.small,
          right: KedisSpacing.xSmall,
          top: KedisSpacing.xSmall,
          bottom: KedisSpacing.xSmall,
        ),
        leading: Checkbox(value: task.isCompleted, onChanged: null),
        title: TextField(
          key: ValueKey('task-edit-input-${task.id}'),
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          textCapitalization: TextCapitalization.sentences,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: const InputDecoration(
            filled: false,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onCancel,
              tooltip: 'Cancel editing',
              icon: const Icon(Icons.close_rounded),
              color: colorScheme.onSurfaceVariant,
            ),
            IconButton(
              onPressed: onSave,
              tooltip: 'Save changes',
              icon: const Icon(Icons.check_rounded),
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
