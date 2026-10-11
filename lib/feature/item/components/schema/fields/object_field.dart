import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/schema/fields/section.dart';
import 'package:stelaris/feature/item/components/schema/schema_field.dart';
import 'package:stelaris/feature/item/components/schema/schema_value.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/component.dart';

/// The fields of an object value.
///
/// The required fields and the optional ones that are set come first, each
/// optional one with a button to remove it again. The optional fields that
/// are not set wait below as chips, so a component with many of them, like
/// `minecraft:equippable`, shows only what it uses.
class ObjectField extends StatelessWidget {
  const ObjectField({
    required this.label,
    required this.schema,
    required this.values,
    required this.onChanged,
    super.key,
  });

  final String? label;
  final ObjectSchema schema;
  final Map<String, Object?> values;
  final ValueChanged<Object?> onChanged;

  void _set(String name, Object? value) => onChanged({...values, name: value});

  void _toggle(String name, ComponentField field, bool include) => onChanged(
    include
        ? {...values, name: initialValue(field.schema)}
        : ({...values}..remove(name)),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = schema.fields.entries;
    final missing = [
      for (final entry in entries)
        if (entry.value.optional && !values.containsKey(entry.key)) entry,
    ];
    final children = [
      for (final entry in entries)
        if (!entry.value.optional || values.containsKey(entry.key))
          _buildField(l10n, entry.key, entry.value),
      if (missing.isNotEmpty) _MoreFields(fields: missing, onAdd: _add),
    ];
    final label = this.label;
    // The top level object of a component needs no frame, the dialog is one.
    if (label == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spaced(children),
      );
    }
    return SchemaSection(title: label, children: children);
  }

  void _add(String name, ComponentField field) => _toggle(name, field, true);

  Widget _buildField(AppLocalizations l10n, String name, ComponentField field) {
    if (!field.optional) {
      return SchemaField(
        schema: field.schema,
        value: values[name],
        label: field.label,
        onChanged: (value) => _set(name, value),
      );
    }
    final remove = IconButton(
      key: Key('component_remove_field_$name'),
      icon: const Icon(Icons.close),
      tooltip: l10n.component_field_remove(field.label),
      onPressed: () => _toggle(name, field, false),
    );
    // A single line input shows the button inside, everything else beside.
    final inside = SchemaField.takesSuffix(field.schema);
    final input = SchemaField(
      schema: field.schema,
      value: values[name],
      label: field.label,
      suffix: inside ? remove : null,
      onChanged: (value) => _set(name, value),
    );
    if (inside) return input;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: input),
        remove,
      ],
    );
  }
}

/// The optional fields that are not set, as chips which add them.
class _MoreFields extends StatelessWidget {
  const _MoreFields({required this.fields, required this.onAdd});

  final List<MapEntry<String, ComponentField>> fields;
  final void Function(String name, ComponentField field) onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.component_field_more,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final MapEntry(key: name, value: field) in fields)
              ActionChip(
                key: Key('component_add_field_$name'),
                avatar: const Icon(Icons.add),
                label: Text(field.label),
                onPressed: () => onAdd(name, field),
              ),
          ],
        ),
      ],
    );
  }
}
