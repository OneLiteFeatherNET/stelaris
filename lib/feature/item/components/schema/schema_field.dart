import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/schema/fields/color_field.dart';
import 'package:stelaris/feature/item/components/schema/fields/list_field.dart';
import 'package:stelaris/feature/item/components/schema/fields/number_field.dart';
import 'package:stelaris/feature/item/components/schema/fields/object_field.dart';
import 'package:stelaris/feature/item/components/schema/fields/registry_tag_field.dart';
import 'package:stelaris/feature/item/components/schema/fields/section.dart';
import 'package:stelaris/feature/item/components/schema/schema_shape.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/component.dart';

/// Renders the input for a value of the given [schema].
///
/// Nested schemas render nested fields, so a whole component value is edited
/// through a single [SchemaField]. Every change produces a new value; maps and
/// lists are copied, never mutated.
class SchemaField extends StatelessWidget {
  const SchemaField({
    required this.schema,
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  final ComponentSchema schema;
  final Object? value;
  final ValueChanged<Object?> onChanged;

  /// The label of the field, null for the top level value of a component.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final schema = this.schema;
    final l10n = context.l10n;
    return switch (schema) {
      IntSchema(:final min, :final max) => NumberField(
        label: label,
        text: value?.toString() ?? '',
        min: min,
        max: max,
        parse: int.tryParse,
        onChanged: onChanged,
      ),
      FloatSchema(:final min, :final max) => NumberField(
        label: label,
        text: value?.toString() ?? '',
        min: min,
        max: max,
        decimal: true,
        parse: double.tryParse,
        onChanged: onChanged,
      ),
      BoolSchema() => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label ?? l10n.component_field_enabled),
        value: value as bool? ?? false,
        onChanged: onChanged,
      ),
      UnitSchema() => SchemaHint(l10n.component_no_value),
      StringSchema() || TextSchema() => TextFormField(
        initialValue: value as String? ?? '',
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        maxLines: schema is TextSchema ? null : 1,
        onChanged: onChanged,
      ),
      KeySchema(:final registry) => TextFormField(
        initialValue: value as String? ?? '',
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          hintText: 'minecraft:…',
          helperText: registry == null
              ? null
              : l10n.component_key_helper(registry),
        ),
        // Shown only when the field is required or switched on, so it always
        // needs a key: the codecs can't read an empty one.
        validator: (text) => switch (text) {
          null || '' => l10n.component_key_required,
          final key when !_keyPattern.hasMatch(key) =>
            l10n.component_key_invalid,
          _ => null,
        },
        onChanged: onChanged,
      ),
      EnumSchema(:final values) => DropdownButtonFormField<String>(
        initialValue: value as String?,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        items: [
          for (final entry in values)
            DropdownMenuItem(value: entry, child: Text(_readable(entry))),
        ],
        onChanged: onChanged,
      ),
      ColorSchema() => ColorField(
        label: label,
        value: value as int? ?? 0xFFFFFF,
        onChanged: onChanged,
      ),
      ListSchema() => switch (flattened(schema, (value as List?) ?? const [])) {
        (:final name, :final field) => SchemaField(
          label: label ?? field.label,
          schema: field.schema,
          value: unwrap(name, (value as List?) ?? const []),
          onChanged: (inner) => onChanged(wrap(name, inner)),
        ),
        null => ListField(
          label: label,
          schema: schema,
          values: (value as List?) ?? const [],
          onChanged: onChanged,
        ),
      },
      RegistryTagSchema() => RegistryTagField(
        label: label,
        schema: schema,
        value: value,
        onChanged: onChanged,
      ),
      ObjectSchema() => ObjectField(
        label: label,
        schema: schema,
        values: (value as Map?)?.cast<String, Object?>() ?? const {},
        onChanged: onChanged,
      ),
      UnsupportedSchema(:final javaType) => SchemaHint(
        '${label == null ? '' : '$label: '}'
        '${l10n.component_not_editable_type(javaType)}',
      ),
    };
  }
}

final RegExp _keyPattern = RegExp(r'^[a-z0-9_.-]+:[a-z0-9_./-]+$');

/// `light_blue` becomes `Light Blue`.
String _readable(String value) => value
    .split('_')
    .map(
      (part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
    )
    .join(' ');
