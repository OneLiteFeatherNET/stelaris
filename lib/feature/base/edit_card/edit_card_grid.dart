import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_dialogs.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';

/// The fields of a detail page in [sections], each with its heading. In a
/// section the cards fill as many columns as fit.
class EditCardGrid extends StatelessWidget {
  const EditCardGrid({required this.sections, super.key});

  /// The widest a card gets before another column fits.
  static const double _maxCardExtent = 320;
  static const double _spacing = 12;
  static const double _padding = 16;

  final List<EditSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 2 * _padding;
        final columns = ((width + _spacing) / (_maxCardExtent + _spacing))
            .floor()
            .clamp(1, 4);
        // Floored, so rounding never pushes the last card into a new row.
        final cardWidth = ((width - _spacing * (columns - 1)) / columns)
            .floorToDouble();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (index, section) in sections.indexed) ...[
                if (index > 0) const SizedBox(height: 24),
                Text(
                  section.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: _spacing,
                  runSpacing: _spacing,
                  children: [
                    for (final field in section.fields)
                      SizedBox(
                        width: cardWidth,
                        child: EditCard(
                          icon: field.icon,
                          label: field.label,
                          value: switch (field) {
                            TextEdit(:final value) => value,
                          },
                          footer: field.footer,
                          onTap: () => editField(context, field),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
