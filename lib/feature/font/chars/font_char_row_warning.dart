import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/util/font_part.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Warns when the lines of a font differ in length, which Minecraft rejects.
/// Shows nothing while there is only one length.
///
/// It only sees the loaded lines, a longer font is checked as far as it is
/// scrolled.
class FontCharRowWarning extends StatelessWidget {
  const FontCharRowWarning({required this.lengths, super.key});

  /// The distinct lengths of the lines, see [rowLengths].
  final List<int> lengths;

  @override
  Widget build(BuildContext context) {
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
