import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:stelaris/util/typedefs.dart';

class DeleteDialog<E> extends StatelessWidget {
  const DeleteDialog({
    required this.title,
    required this.header,
    required this.value,
    required this.successfully,
    super.key,
  });

  final String title;
  final List<TextSpan> header;
  final E value;
  final MapToDeleteSuccessfully<E> successfully;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FormDialog(
      title: title,
      actionIcon: Icons.delete_outline,
      actionLabel: context.l10n.tooltip_delete,
      actionColor: theme.colorScheme.error,
      maxWidth: 420,
      onSubmit: () {
        if (successfully(value)) {
          Navigator.of(context).pop(true);
        }
      },
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(text: TextSpan(children: header)),
          verticalSpacing10,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                horizontalSpacing10,
                Expanded(
                  child: Text(
                    context.l10n.delete_dialog_irreversible,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
