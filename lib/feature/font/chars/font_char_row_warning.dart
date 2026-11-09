import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/util/font_part.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Warns when the lines of a font differ in length, which Minecraft rejects.
/// Shows nothing while they are all the same length.
///
/// It only sees the loaded lines, a longer font is checked as far as it is
/// scrolled.
class FontCharRowWarning extends StatelessWidget {
  const FontCharRowWarning({required this.lines, super.key});

  final Iterable<String> lines;

  @override
  Widget build(BuildContext context) {
    final lengths = rowLengths(lines);
    if (lengths.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NoticeBox(
        icon: Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.error,
        content: Text(context.l10n.font_char_rows_differ(lengths.join(', '))),
      ),
    );
  }
}
