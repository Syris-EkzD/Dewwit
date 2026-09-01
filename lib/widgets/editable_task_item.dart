import 'package:dewwit/theme/dewwit_design.dart';
import 'package:flutter/material.dart';

class EditableTaskItem extends StatefulWidget {
  const EditableTaskItem({
    required this.controller,
    required this.focusNode,
    required this.onFinish,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onFinish;

  @override
  State<EditableTaskItem> createState() => _EditableTaskItemState();
}

class _EditableTaskItemState extends State<EditableTaskItem> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_draftChanged);
  }

  @override
  void didUpdateWidget(EditableTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_draftChanged);
      widget.controller.addListener(_draftChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_draftChanged);
    super.dispose();
  }

  void _draftChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasTitle = widget.controller.text.trim().isNotEmpty;

    return Material(
      color: colorScheme.primaryContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(DewwitRadii.medium),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.only(
          left: DewwitSpacing.small,
          right: DewwitSpacing.small,
          top: DewwitSpacing.xSmall,
          bottom: DewwitSpacing.xSmall,
        ),
        leading: const Checkbox(value: false, onChanged: null),
        title: TextField(
          key: const ValueKey('task-draft-input'),
          controller: widget.controller,
          focusNode: widget.focusNode,
          autofocus: true,
          minLines: 1,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          textCapitalization: TextCapitalization.sentences,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: const InputDecoration(
            hintText: 'What needs doing?',
            filled: false,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onTapOutside: (_) => widget.focusNode.unfocus(),
        ),
        trailing: IconButton(
          onPressed: widget.onFinish,
          tooltip: hasTitle ? 'Save task' : 'Discard draft',
          icon: Icon(hasTitle ? Icons.check_rounded : Icons.close_rounded),
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
