import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/auth/roles.dart';
import 'package:stelaris/feature/auth/role_gate.dart';
import 'package:stelaris/feature/base/chips/number_badge.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/font_part.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// One font char line as a card in the style of the lore cards: the row
/// number, the code points, their count and the copy and delete actions. A
/// tap on the card edits the line.
///
/// The line shows as hex code points, Flutter has no glyph for the characters
/// of the Private Use Area. Every code point sits in a cell of the same
/// width, so the columns of the rows line up.
class CharListItem extends StatefulWidget {
  const CharListItem({
    required this.fontString,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    this.expectedLength,
    this.codePointWidth,
    super.key,
  });

  final FontStringDTO fontString;

  /// The position in the list, the row of the texture the line stands for.
  final int index;

  /// The length all lines of the font should have, see [expectedRowLength].
  /// A line of another length marks its count.
  final int? expectedLength;

  /// The width of the cell of a code point, see [codePointCellWidth]. The
  /// list measures it once for all its cards, measured here when `null`.
  final double? codePointWidth;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<CharListItem> createState() => _CharListItemState();
}

class _CharListItemState extends State<CharListItem> {
  /// Whether the mouse is over the buttons. The card is a button too, and
  /// its hover would light it up behind the button the mouse is over.
  bool _overActions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fontString = widget.fontString;
    final length = fontString.line.runes.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card.filled(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppShapes.medium),
        ),
        child: InkWell(
          onTap: widget.onEdit,
          overlayColor: _overActions
              ? const WidgetStatePropertyAll(Colors.transparent)
              : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
            child: Row(
              children: [
                NumberBadge(number: widget.index + 1),
                const SizedBox(width: 12),
                Expanded(
                  child: _CodePoints(
                    line: fontString.line,
                    cellWidth:
                        widget.codePointWidth ?? codePointCellWidth(context),
                  ),
                ),
                const SizedBox(width: 8),
                _LengthBadge(
                  length: length,
                  expectedLength: widget.expectedLength,
                ),
                const SizedBox(width: 8),
                MouseRegion(
                  onEnter: (_) => setState(() => _overActions = true),
                  onExit: (_) => setState(() => _overActions = false),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: context.l10n.tooltip_copy_to_clipboard,
                        onPressed: () => _copy(context),
                        icon: const Icon(Icons.copy_outlined),
                      ),
                      // A tap on the card edits, so only deleting needs a button.
                      RoleGate(
                        role: Roles.admin,
                        child: IconButton(
                          tooltip: context.l10n.tooltip_delete,
                          onPressed: widget.onDelete,
                          icon: const Icon(Icons.delete_forever),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Copies the characters themselves, ready to paste into chat, lore or a
  /// config.
  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.fontString.line));
    if (!context.mounted) return;
    context.showSuccessSnackBar(context.l10n.snackbar_copied_to_clipboard);
  }
}

/// The style of a code point: the body text with digits of the same width.
TextStyle? _codePointStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodyLarge
        ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

/// The width of a cell that holds a code point of four digits like `FFFF`.
/// The app font has no monospace letters on the web, cells of this width
/// line the columns of the rows up anyway.
double codePointCellWidth(BuildContext context) {
  final painter = TextPainter(
    text: TextSpan(text: 'FFFF', style: _codePointStyle(context)),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
}

/// The code points of a line, each in a cell at least [cellWidth] wide. A
/// code point above FFFF widens its cell.
class _CodePoints extends StatelessWidget {
  const _CodePoints({required this.line, required this.cellWidth});

  final String line;
  final double cellWidth;

  @override
  Widget build(BuildContext context) {
    final style = _codePointStyle(context);
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final codePoint in formatCodePoints(line).split(' '))
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: cellWidth),
            child: Text(codePoint, style: style),
          ),
      ],
    );
  }
}

/// The number of code points in the line, in the error colors when it
/// differs from the length the lines should have.
class _LengthBadge extends StatelessWidget {
  const _LengthBadge({required this.length, required this.expectedLength});

  final int length;
  final int? expectedLength;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final expected = expectedLength;
    final deviates = expected != null && length != expected;
    return Tooltip(
      message: deviates
          ? context.l10n.font_char_length_deviates(length, expected)
          : context.l10n.font_char_length(length),
      child: NumberBadge(
        key: const Key('font_char_length'),
        number: length,
        background: deviates
            ? colorScheme.errorContainer
            : colorScheme.surfaceContainerHighest,
        foreground: deviates
            ? colorScheme.onErrorContainer
            : colorScheme.onSurfaceVariant,
      ),
    );
  }
}
