import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/typedefs.dart';

/// Delete dialog for a whole model. The user has to type the model's name
/// before the delete button is enabled.
class ModelDeleteDialog<E> extends StatefulWidget {
  const ModelDeleteDialog({
    required this.title,
    required this.name,
    required this.value,
    required this.successfully,
    this.namespacedKey,
    this.warning,
    super.key,
  });

  final String title;
  final String name;
  final E value;
  final MapToDeleteSuccessfully<E> successfully;
  final String? namespacedKey;

  /// Which related data gets deleted as well.
  final String? warning;

  @override
  State<ModelDeleteDialog<E>> createState() => _ModelDeleteDialogState<E>();
}

class _ModelDeleteDialogState<E> extends State<ModelDeleteDialog<E>> {
  final TextEditingController _controller = TextEditingController();

  bool get _canDelete => _controller.text.trim() == widget.name.trim();

  void _delete() {
    if (!_canDelete) return;
    if (widget.successfully(widget.value)) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    final namespacedKey = widget.namespacedKey;

    return FormDialog(
      title: widget.title,
      actionIcon: Icons.delete_outline,
      actionLabel: context.l10n.tooltip_delete,
      actionColor: errorColor,
      maxWidth: 420,
      onSubmit: _canDelete ? _delete : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (namespacedKey != null) ...[
            const SizedBox(height: 4),
            Center(
              child: InfoChip(
                icon: Icons.vpn_key_outlined,
                text: namespacedKey,
              ),
            ),
          ],
          const Divider(height: 24),
          NoticeBox(
            icon: Icons.warning_amber_rounded,
            color: errorColor,
            content: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: context.l10n.delete_dialog_irreversible,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (widget.warning != null)
                    TextSpan(text: ' ${widget.warning}'),
                ],
              ),
            ),
          ),
          verticalSpacing10,
          SelectableText.rich(
            TextSpan(
              children: [
                TextSpan(text: context.l10n.delete_dialog_type_name_before),
                TextSpan(
                  text: widget.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: context.l10n.delete_dialog_type_name_after),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _delete(),
          ),
        ],
      ),
    );
  }
}
