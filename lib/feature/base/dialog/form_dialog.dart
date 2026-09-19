import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Shared chrome for form-style dialogs: a rounded card with a title row
/// (with a close icon), a scrollable content area and a confirm/cancel
/// action row.
///
/// This is the standard dialog shape used across the app (see
/// [ModelCreateDialog] for the dialog this design originates from).
class FormDialog extends StatelessWidget {
  const FormDialog({
    required this.title,
    required this.content,
    required this.actionLabel,
    required this.onSubmit,
    this.actionIcon,
    this.actionColor,
    this.onCancel,
    this.minWidth = 0,
    this.maxWidth = 520,
    this.maxHeight = 650,
    super.key,
  });

  final String title;
  final Widget content;
  final IconData? actionIcon;
  final String actionLabel;

  /// Overrides the action button's background color, e.g. for destructive
  /// actions like a delete confirmation.
  final Color? actionColor;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;
  final double minWidth;
  final double maxWidth;
  final double maxHeight;

  void _handleCancel(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (onCancel != null) {
      onCancel!.call();
    } else {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _handleCancel(context),
                    icon: const Icon(Icons.close),
                    splashRadius: 20,
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(child: SingleChildScrollView(child: content)),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _handleCancel(context),
                    child: Text(context.l10n.button_cancel),
                  ),
                  horizontalSpacing10,
                  actionIcon == null
                      ? FilledButton(
                          style: actionColor == null
                              ? null
                              : FilledButton.styleFrom(backgroundColor: actionColor),
                          onPressed: onSubmit,
                          child: Text(actionLabel),
                        )
                      : FilledButton.icon(
                          style: actionColor == null
                              ? null
                              : FilledButton.styleFrom(backgroundColor: actionColor),
                          onPressed: onSubmit,
                          icon: Icon(actionIcon),
                          label: Text(actionLabel),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
