import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/service/generator/generator_models.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// The body of a generator tab: its sections stacked on the page's 16 inset,
/// as on a detail page.
class GeneratorTabBody extends StatelessWidget {
  const GeneratorTabBody({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (index, child) in children.indexed) ...[
          if (index > 0) const SizedBox(height: 16),
          child,
        ],
      ],
    );
  }
}

/// Two groups of sections side by side once the tab is wide enough, so a
/// wide screen shows more at once; stacked below that.
class GeneratorColumns extends StatelessWidget {
  const GeneratorColumns({
    required this.start,
    required this.end,
    this.startFlex = 3,
    this.endFlex = 2,
    super.key,
  });

  /// The width from which the two groups stand side by side.
  static const double breakpoint = 1100;

  final List<Widget> start;
  final List<Widget> end;
  final int startFlex;
  final int endFlex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint || end.isEmpty) {
          return _stack([...start, ...end]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: startFlex, child: _stack(start)),
            const SizedBox(width: 16),
            Expanded(flex: endFlex, child: _stack(end)),
          ],
        );
      },
    );
  }

  static Widget _stack(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final (index, child) in children.indexed) ...[
        if (index > 0) const SizedBox(height: 16),
        child,
      ],
    ],
  );
}

/// A section of a generator tab: an [EditSectionCard] with its heading.
class GeneratorSection extends StatelessWidget {
  const GeneratorSection({
    required this.title,
    required this.children,
    this.trailing,
    super.key,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return EditSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditSectionHeading(title: title, trailing: trailing),
          for (final child in children) ...[const SizedBox(height: 16), child],
        ],
      ),
    );
  }
}

/// Says that the page shows simulated data.
class GeneratorDemoBanner extends StatelessWidget {
  const GeneratorDemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: colors.tertiaryContainer,
      shape: AppShapes.rounded(AppShapes.medium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.science_outlined,
              size: 20,
              color: colors.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.l10n.generator_demo_banner,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Body text of a section, in the muted colour of the edit cards.
class GeneratorText extends StatelessWidget {
  const GeneratorText(this.text, {this.emphasized = false, super.key});

  final String text;

  /// Whether this is the line the user has to act on.
  final bool emphasized;

  /// Lines longer than this are hard to read on a wide screen.
  static const double maxWidth = 760;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget body = Text(
      text,
      style: emphasized
          ? theme.textTheme.bodyMedium
          : theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: body,
      ),
    );
  }
}

/// A line with an [icon], for results and warnings inside a section.
class GeneratorNote extends StatelessWidget {
  const GeneratorNote(
    this.text, {
    this.icon = Icons.info_outline,
    this.color,
    super.key,
  });

  final String text;
  final IconData icon;

  /// The colour of the icon, muted when null.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}

/// A small spinner with [text] next to it.
class GeneratorLoading extends StatelessWidget {
  const GeneratorLoading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Expanded(child: GeneratorText(text)),
      ],
    );
  }
}

/// The detail lines of [failure]: what the service said, or what the kind
/// of failure means when it said nothing, and the status.
List<String> failureDetails(AppLocalizations l10n, GeneratorFailure failure) {
  final String? message = failure.message;
  return [
    if (message != null && message.trim().isNotEmpty)
      message
    else if (failure.kind == GeneratorFailureKind.network)
      l10n.generator_error_network
    else if (failure.kind == GeneratorFailureKind.unavailable)
      l10n.generator_error_unavailable,
    if (failure.statusCode != null)
      l10n.generator_error_status('${failure.statusCode}'),
  ];
}

/// A failed request, as the other pages show one: [title] in the error
/// colour, the details of [failure] below it, and a retry.
class GeneratorError extends StatelessWidget {
  const GeneratorError({
    required this.title,
    required this.failure,
    this.onRetry,
    super.key,
  });

  final String title;
  final GeneratorFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final List<String> details = failureDetails(context.l10n, failure);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline, size: 20, color: colors.error),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                ),
              ),
              for (final line in details)
                Text(
                  line,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: Text(context.l10n.generator_retry),
          ),
      ],
    );
  }
}

/// Copies [text] and confirms it.
Future<void> copyToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    context.showInfoSnackBar(context.l10n.generator_copied);
  }
}

/// The main button of a section; shows a spinner instead of its icon while
/// [busy], as the page header's actions do.
class GeneratorActionButton extends StatelessWidget {
  const GeneratorActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.busy = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}
