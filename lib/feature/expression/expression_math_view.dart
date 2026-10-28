import 'package:flutter_math_fork/flutter_math.dart';
import 'package:material_ui/material_ui.dart';

/// A formula typeset as math, read-only. [tex] is its LaTeX, see
/// [expressionToTex]. A long formula breaks after its operators and relations
/// and continues on the next line, so it stays inside the width it is given.
/// A single part wider than that scrolls sideways. Without [tex], or when the
/// LaTeX does not render, the [formula] text is shown in monospace instead.
class ExpressionMathView extends StatelessWidget {
  const ExpressionMathView({
    required this.formula,
    required this.tex,
    required this.fontSize,
    super.key,
  });

  /// The EvalEx text, shown when [tex] cannot be drawn.
  final String formula;

  /// The LaTeX of the formula, or null when it does not convert.
  final String? tex;

  /// The size of the math and of the text fallback.
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyle = TextStyle(color: colors.onSurface, fontSize: fontSize);

    Widget raw() =>
        Text(formula, style: textStyle.copyWith(fontFamily: 'monospace'));

    final source = tex;
    if (source == null) return raw();
    final math = Math.tex(
      source,
      mathStyle: MathStyle.display,
      textStyle: textStyle,
      onErrorFallback: (_) => raw(),
    );
    final List<Math> parts;
    try {
      parts = math.texBreak().parts;
    } on Object {
      // Breaking failed: the whole formula scrolls sideways, as it did before.
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: math,
      );
    }
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final part in parts)
          // A part is one unbreakable run, e.g. a fraction. Only one wider
          // than the line scrolls, the others wrap.
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: part),
      ],
    );
  }
}
