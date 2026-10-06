import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/schema/fields/list_field.dart';
import 'package:stelaris/feature/item/components/schema/fields/section.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/component.dart';

/// The input of a set of registry entries: either a list of keys or a single
/// `#tag` reference, never a tag inside the list.
///
/// A string value is a tag, anything else is edited as the list. Switching
/// between both starts the other form empty.
class RegistryTagField extends StatelessWidget {
  const RegistryTagField({
    required this.label,
    required this.schema,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String? label;
  final RegistryTagSchema schema;
  final Object? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = this.value;
    final mode = _ModeSwitch(
      tag: value is String,
      onChanged: (tag) => onChanged(tag ? '' : <Object?>[]),
    );
    if (value is! String) {
      return ListField(
        label: label,
        schema: ListSchema(KeySchema(registry: schema.registry)),
        values: (value as List?) ?? const [],
        onChanged: onChanged,
        action: mode,
      );
    }
    final registry = schema.registry;
    return SchemaSection(
      title: label ?? l10n.component_field_entries,
      trailing: mode,
      children: [
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: '#minecraft:…',
            helperText: registry == null
                ? null
                : l10n.component_tag_helper(registry),
          ),
          validator: (text) => switch (text) {
            null || '' => l10n.component_tag_required,
            final tag when !_tagPattern.hasMatch(tag) =>
              l10n.component_tag_invalid,
            _ => null,
          },
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.tag, required this.onChanged});

  final bool tag;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: [
        ButtonSegment(
          value: false,
          label: Text(context.l10n.component_tag_mode_keys),
        ),
        ButtonSegment(
          value: true,
          label: Text(context.l10n.component_tag_mode_tag),
        ),
      ],
      selected: {tag},
      onSelectionChanged: (selected) => onChanged(selected.single),
    );
  }
}

final RegExp _tagPattern = RegExp(r'^#[a-z0-9_.-]+:[a-z0-9_./-]+$');
