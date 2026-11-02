import 'package:flutter_math_fork/flutter_math.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/app_shapes.dart';

/// A formula typeset as math, read-only. [tex] is its LaTeX, see
/// [expressionToTex]. A long formula breaks after its operators and relations
/// and continues on the next line, so it stays inside the width it is given.
/// A single part wider than that scrolls sideways. Without [tex], or when the
/// LaTeX does not render, the [formula] text is shown in monospace instead.
class ExpressionMathView extends StatefulWidget {
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
  State<ExpressionMathView> createState() => _ExpressionMathViewState();
}

class _ExpressionMathViewState extends State<ExpressionMathView> {
  /// The inputs the typeset widget was built for, and that widget. Breaking
  /// the math into parts is the costly part, so it is kept while the inputs
  /// stay the same.
  ({String formula, String? tex, double fontSize, Color color})? _inputs;
  Widget? _typeset;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final inputs = (
      formula: widget.formula,
      tex: widget.tex,
      fontSize: widget.fontSize,
      color: color,
    );
    if (inputs != _inputs) {
      _inputs = inputs;
      _typeset = _typesetWith(inputs);
    }
    return _typeset!;
  }

  /// The formula drawn as [inputs] say: the math in parts, or the text.
  static Widget _typesetWith(
    ({String formula, String? tex, double fontSize, Color color}) inputs,
  ) {
    final textStyle = TextStyle(color: inputs.color, fontSize: inputs.fontSize);

    Widget raw() => Text(
      inputs.formula,
      style: textStyle.copyWith(fontFamily: 'monospace'),
    );

    final source = inputs.tex;
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

/// The typeset formula on a surface of its own under the editor, with its
/// [label] above it, so the result stands apart from the text it comes from.
class ExpressionMathPanel extends StatelessWidget {
  const ExpressionMathPanel({
    required this.label,
    required this.child,
    super.key,
  });

  /// The size the panels typeset their formula in.
  static const double fontSize = 22;

  final String label;

  /// The formula, typically an [ExpressionMathView] in [fontSize].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: colors.surfaceContainerHighest,
        shape: AppShapes.rounded(AppShapes.small),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
