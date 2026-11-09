import 'package:material_ui/material_ui.dart';

/// The share of a field's `maxLength` from which [nearLimitCounter] shows
/// the counter.
const double counterThreshold = 0.8;

/// A `buildCounter` for text fields that shows "current/max" only once the
/// text reaches [counterThreshold] of the limit, so fields that rarely get
/// long don't carry a "0/255" below them.
///
/// Below that there is no counter line at all, so these fields keep the
/// same spacing as fields without a limit; the field grows by the line once
/// the counter appears, like it does for an error.
Widget? nearLimitCounter(
  BuildContext context, {
  required int currentLength,
  required int? maxLength,
  required bool isFocused,
}) {
  if (maxLength == null || currentLength < maxLength * counterThreshold) {
    return null;
  }
  final theme = Theme.of(context);
  final style = theme.textTheme.bodySmall?.copyWith(
    color: theme.colorScheme.onSurfaceVariant,
  );
  return Text('$currentLength/$maxLength', style: style);
}
