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
    this.destructive = false,
    this.minWidth = 0,
    this.maxWidth = 520,
    this.maxHeight = 650,
    this.showActions = true,
    this.busy = false,
    super.key,
  });

  final String title;
  final Widget content;
  final IconData? actionIcon;
  final String actionLabel;

  /// Paints the action button in the error colors, e.g. for a delete
  /// confirmation.
  final bool destructive;
  final VoidCallback? onSubmit;
  final double minWidth;
  final double maxWidth;
  final double maxHeight;

  /// Hides the cancel/confirm row for dialogs with their own action button.
  final bool showActions;

  /// Keeps the dialog open while its action runs: close, cancel and Esc do
  /// nothing, so a result can't arrive after the dialog is gone.
  final bool busy;

  void _handleCancel(BuildContext context) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionStyle = destructive
        ? FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          )
        : null;

    return PopScope(
      canPop: !busy,
      child: Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: minWidth,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          // No padding on the right: the content reaches into it, so its
          // scrollbar runs beside the fields instead of over them.
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 0, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Gutter(
                  child: Row(
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
                        onPressed: busy ? null : () => _handleCancel(context),
                        icon: const Icon(Icons.close),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
                const _Gutter(child: Divider(height: 24)),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(right: _gutter),
                    child: content,
                  ),
                ),
                if (showActions) ...[
                  const _Gutter(child: Divider(height: 24)),
                  _Gutter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: busy ? null : () => _handleCancel(context),
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
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The padding of the dialog on the right, which the scrolling content
/// reaches into.
const double _gutter = 24;

/// Keeps the parts outside the content clear of the right edge.
class _Gutter extends StatelessWidget {
  const _Gutter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: _gutter),
      child: child,
    );
  }
}
