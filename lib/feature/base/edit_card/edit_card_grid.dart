import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/base/edit_card/edit_dialogs.dart';
import 'package:stelaris/feature/base/edit_card/edit_field.dart';
import 'package:stelaris/feature/base/edit_card/edit_section_heading.dart';
import 'package:stelaris/feature/component/component_preview.dart';

/// The fields of a detail page in [sections], each with its heading. In a
/// section the cards fill as many columns as fit.
class EditCardGrid extends StatelessWidget {
  const EditCardGrid({required this.sections, this.header, super.key});

  /// The widest a card gets before another column fits.
  static const double _maxCardExtent = 320;
  static const double _spacing = 12;
  static const double _padding = 16;

  final List<EditSection> sections;

  /// Shown above the sections and scrolled with them, e.g. toggles that
  /// change in place.
  final Widget? header;

  @override
  Widget build(BuildContext context) {
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
              if (header case final header?) ...[
                header,
                const SizedBox(height: 24),
              ],
              for (final (index, section) in sections.indexed) ...[
                if (index > 0) const SizedBox(height: 24),
                EditSectionHeading(title: section.title),
                const SizedBox(height: 8),
                Wrap(
                  spacing: _spacing,
                  runSpacing: _spacing,
                  children: [
                    for (final field in section.fields)
                      SizedBox(
                        // Keeps each card's hover and focus when a field
                        // comes or goes, like the background of a root.
                        key: ValueKey(field.label),
                        // A text component takes the full row.
                        width: field is TextComponentEdit ? width : cardWidth,
                        child: _card(context, field),
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

  Widget _card(BuildContext context, EditField field) {
    final text = switch (field) {
      TextEdit(:final value) => value,
      ChoiceEdit() => field.displayValue,
      TextComponentEdit(:final value) => textComponentSource(value),
    };
    return EditCard(
      icon: field.icon,
      label: field.label,
      value: text,
      footer: field.footer,
      preview: switch (field) {
        TextComponentEdit(:final componentContext) => ComponentPreview(
          text: text,
          componentContext: componentContext,
        ),
        _ => null,
      },
      onTap: () => editField(context, field),
    );
  }
}
