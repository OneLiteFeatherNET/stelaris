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
    this.minWidth = 0,
    this.maxWidth = 520,
    this.maxHeight = 650,
    this.showActions = true,
    super.key,
  });

  final String title;
  final Widget content;
  final IconData? actionIcon;
  final String actionLabel;

  /// Overrides the action button's background color, e.g. for destructive
  /// actions like a delete confirmation.
  final Color? actionColor;
  final VoidCallback? onSubmit;
  final double minWidth;
  final double maxWidth;
  final double maxHeight;

  /// Hides the cancel/confirm row for dialogs with their own action button.
  final bool showActions;

  void _handleCancel(BuildContext context) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionStyle = actionColor == null
        ? null
        : FilledButton.styleFrom(backgroundColor: actionColor);

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
              if (showActions) ...[
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
                            style: actionStyle,
                            onPressed: onSubmit,
                            child: Text(actionLabel),
                          )
                        : FilledButton.icon(
                            style: actionStyle,
                            onPressed: onSubmit,
                            icon: Icon(actionIcon),
                            label: Text(actionLabel),
                          ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
