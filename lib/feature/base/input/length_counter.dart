import 'package:material_ui/material_ui.dart';

/// The share of a field's `maxLength` from which [nearLimitCounter] shows
/// the counter.
const double counterThreshold = 0.8;

/// A `buildCounter` for text fields that shows "current/max" only once the
/// text reaches [counterThreshold] of the limit, so fields that rarely get
/// long don't carry a "0/255" below them.
///
/// Keeps an empty line before that, so the field doesn't grow when the
/// counter appears.
Widget? nearLimitCounter(
  BuildContext context, {
  required int currentLength,
  required int? maxLength,
  required bool isFocused,
}) {
  if (maxLength == null) return null;
  final theme = Theme.of(context);
  final style = theme.textTheme.bodySmall?.copyWith(
    color: theme.colorScheme.onSurfaceVariant,
  );
  if (currentLength < maxLength * counterThreshold) {
    return ExcludeSemantics(child: Text('', style: style));
  }
  return Text('$currentLength/$maxLength', style: style);
}
