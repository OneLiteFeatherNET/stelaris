import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// A heading and the cards under it, with the space to the next section
/// below. A section that shows nothing leaves no space either.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.title,
    required this.children,
    this.trailing,
    super.key,
  });

  final String title;
  final List<Widget> children;

  /// Sits at the right end of the heading, e.g. a reset button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditSectionHeading(title: title, trailing: trailing),
          const SizedBox(height: 8),
          for (final (index, card) in children.indexed) ...[
            if (index > 0) const SizedBox(height: 12),
            card,
          ],
        ],
      ),
    );
  }
}

/// The reset button of a section heading.
class SettingsResetButton extends StatelessWidget {
  const SettingsResetButton({required this.onPressed, super.key});

  /// Null disables the button, the section already has its defaults.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
      child: Text(context.l10n.settings_reset),
    );
  }
}
