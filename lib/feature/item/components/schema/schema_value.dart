import 'package:stelaris/feature/item/components/schema/schema_shape.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:vulpes_data/component.dart';

/// The value a component starts with when it is added: required fields get a
/// sensible default, optional fields are left out.
Object? initialValue(ComponentSchema schema) => switch (schema) {
  IntSchema(:final min) => min ?? 0,
  FloatSchema(:final min) => min ?? 0.0,
  BoolSchema() => false,
  // The vanilla format of a component without a value is an empty object.
  UnitSchema() => const <String, Object?>{},
  StringSchema() || TextSchema() || KeySchema() => '',
  ColorSchema() => 0xFFFFFF,
  EnumSchema(:final values) => values.first,
  ListSchema() => <Object?>[],
  ObjectSchema(:final fields) => <String, Object?>{
    for (final entry in fields.entries)
      if (!entry.value.optional) entry.key: initialValue(entry.value.schema),
  },
  UnsupportedSchema() => null,
};

/// A one line description of a component [value], shown on its card.
String summarize(
  AppLocalizations l10n,
  ComponentSchema schema,
  Object? value,
) => switch (schema) {
  UnitSchema() => l10n.component_summary_set,
  ColorSchema() when value is int => colorHex(value),
  ListSchema() when value is List => l10n.component_summary_entries(
    switch (flattened(schema)) {
      (:final name, field: _) => unwrap(name, value).length,
      null => value.length,
    },
  ),
  ObjectSchema(:final fields) when value is Map =>
    value.entries
        .map((e) {
          final field = fields[e.key];
          final text = field == null
              ? '${e.value}'
              : summarize(l10n, field.schema, e.value);
          return '${field?.label ?? e.key}: $text';
        })
        .join(', '),
  UnsupportedSchema() => l10n.component_not_editable,
  _ when value == null || value == '' => '—',
  _ => '$value',
};

/// Formats an RGB integer as `#RRGGBB`.
String colorHex(int rgb) =>
    '#${(rgb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
