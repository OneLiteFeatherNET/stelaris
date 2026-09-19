import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/constants.dart';

/// A tinted callout box used inside dialog content to highlight a preview or
/// a warning, e.g. the resulting `namespace:key` in [ModelCreateDialog] or the
/// "cannot be undone" notice in [DeleteDialog].
class NoticeBox extends StatelessWidget {
  const NoticeBox({
    required this.icon,
    required this.content,
    this.color,
    super.key,
  });

  final IconData icon;
  final Widget content;

  /// Accent color driving the icon, border and background tint.
  /// Defaults to the theme's primary color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: accent),
          horizontalSpacing10,
          Expanded(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: accent),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
