import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:stelaris/util/l10n_ext.dart';

final DateFormat _absoluteFormat = DateFormat('dd.MM.yyyy', 'en_US');

/// Formats [date] as a short, human-readable relative time (e.g. "5 min ago"),
/// falling back to an absolute date once it's more than a week in the past.
String relativeTime(BuildContext context, DateTime date) {
  final difference = DateTime.now().difference(date);
  final l10n = context.l10n;

  if (difference.inSeconds < 60) return l10n.relative_time_just_now;
  if (difference.inMinutes < 60) {
    return l10n.relative_time_minutes_ago(difference.inMinutes);
  }
  if (difference.inHours < 24) {
    return l10n.relative_time_hours_ago(difference.inHours);
  }
  if (difference.inDays < 7) {
    return l10n.relative_time_days_ago(difference.inDays);
  }
  return _absoluteFormat.format(date);
}
