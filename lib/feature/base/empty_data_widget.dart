import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The [EmptyDataWidget] is a widget that displays a message if the model has no data.
/// It is only used when the selected model has no data. Texts left out fall
/// back to the localized defaults.
class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({
    this.header,
    this.subHeader,
    this.icon = Icons.auto_awesome,
    super.key,
  }) : action = null;

  /// Constructor with a required header and default sub header
  ///
  /// Use this when you need to customize the header message but keep the default sub header
  const EmptyDataWidget.standard({
    required String this.header,
    this.subHeader,
    this.icon = Icons.auto_awesome,
    super.key,
  }) : action = null;

  /// Constructor with fully customizable header and sub header
  ///
  /// Use this when you need to customize both the header and sub header messages
  const EmptyDataWidget.full({
    required String this.header,
    required String this.subHeader,
    this.icon = Icons.auto_awesome,
    this.action,
    super.key,
  });

  final String? header;
  final String? subHeader;
  final IconData icon;

  /// Optional button below the texts, e.g. to reset a search.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            header ?? context.l10n.empty_data_default_header,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subHeader ?? context.l10n.empty_data_default_subheader,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}
