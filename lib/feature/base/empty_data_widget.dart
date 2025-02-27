import 'package:flutter/material.dart';

/// The [EmptyDataWidget] is a widget that displays a message if the model has no data.
/// It is only used when the selected model has no data
class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({
    this.header = 'No data available',
    this.subHeader = 'Use the add button to add new data!',
    this.icon = Icons.auto_awesome,
    super.key,
  });

  /// Constructor with a required header and default sub header
  ///
  /// Use this when you need to customize the header message but keep the default sub header
  const EmptyDataWidget.standard({
    required this.header,
    this.subHeader = 'Use the add button to add new data!',
    this.icon = Icons.auto_awesome,
    super.key,
  });

  /// Constructor with fully customizable header and sub header
  ///
  /// Use this when you need to customize both the header and sub header messages
  const EmptyDataWidget.full({
    required this.header,
    required this.subHeader,
    this.icon = Icons.auto_awesome,
    super.key,
  });

  final String header;
  final String subHeader;
  final IconData icon;

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
            header,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subHeader,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
