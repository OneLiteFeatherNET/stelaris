import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
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
    switch (_flattened(schema)) {
      (:final name, field: _) => _unwrap(name, value).length,
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
      IntSchema(:final min, :final max) => _NumberField(
        label: label,
        text: value?.toString() ?? '',
        min: min,
        max: max,
        parse: int.tryParse,
        onChanged: onChanged,
      ),
      FloatSchema(:final min, :final max) => _NumberField(
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
      UnitSchema() => _Hint(l10n.component_no_value),
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
      ColorSchema() => _ColorField(
        label: label,
        value: value as int? ?? 0xFFFFFF,
        onChanged: onChanged,
      ),
      ListSchema() => switch (_flattened(schema)) {
        (:final name, :final field) => _ListField(
          label: label ?? field.label,
          schema: field.schema as ListSchema,
          values: _unwrap(name, (value as List?) ?? const []),
          onChanged: (values) =>
              onChanged(_wrap(name, values! as List<Object?>)),
        ),
        null => _ListField(
          label: label,
          schema: schema,
          values: (value as List?) ?? const [],
          onChanged: onChanged,
        ),
      },
      ObjectSchema() => _ObjectField(
        label: label,
        schema: schema,
        values: (value as Map?)?.cast<String, Object?>() ?? const {},
        onChanged: onChanged,
      ),
      UnsupportedSchema(:final javaType) => _Hint(
        '${label == null ? '' : '$label: '}'
        '${l10n.component_not_editable_type(javaType)}',
      ),
    };
  }
}

/// The field of a list whose entries are objects with nothing but one list,
/// like the block predicates of `minecraft:can_break`; null for other lists.
///
/// Such a list is edited as the one inner list: an item matches if any entry
/// does, so the blocks of two entries do the same in a single one, and the
/// second level of entries only nested the dialog.
({String name, ComponentField field})? _flattened(ListSchema schema) =>
    switch (schema.element) {
      ObjectSchema(:final fields)
          when fields.length == 1 &&
              fields.values.single.schema is ListSchema =>
        (name: fields.keys.single, field: fields.values.single),
      _ => null,
    };

/// The inner lists of all [entries] joined into one.
List<Object?> _unwrap(String name, List<Object?> entries) => [
  for (final entry in entries)
    if (entry is Map && entry[name] is List) ...entry[name] as List,
];

/// The joined [values] as the single entry of a flattened list.
List<Object?> _wrap(String name, List<Object?> values) => [
  if (values.isNotEmpty) {name: values},
];

final RegExp _keyPattern = RegExp(r'^[a-z0-9_.-]+:[a-z0-9_./-]+$');

/// `light_blue` becomes `Light Blue`.
String _readable(String value) => value
    .split('_')
    .map(
      (part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1),
    )
    .join(' ');

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.text,
    required this.min,
    required this.max,
    required this.parse,
    required this.onChanged,
    this.decimal = false,
  });

  final String? label;
  final String text;
  final num? min;
  final num? max;
  final bool decimal;
  final num? Function(String) parse;
  final ValueChanged<Object?> onChanged;

  String? _range(AppLocalizations l10n) => switch ((min, max)) {
    (null, null) => null,
    (final min?, null) => l10n.component_range_min('$min'),
    (null, final max?) => l10n.component_range_max('$max'),
    (final min?, final max?) => l10n.component_range_between('$min', '$max'),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final range = _range(l10n);
    return TextFormField(
      initialValue: text,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        helperText: range,
      ),
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimal,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(decimal ? r'[-0-9.]' : r'[-0-9]'),
        ),
      ],
      validator: (input) {
        if (input == null || input.isEmpty) {
          return l10n.component_value_required;
        }
        final number = parse(input);
        if (number == null) return l10n.component_not_a_number;
        if (min != null && number < min!) return range;
        if (max != null && number > max!) return range;
        return null;
      },
      onChanged: (input) => onChanged(parse(input)),
    );
  }
}

class _ColorField extends StatelessWidget {
  const _ColorField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String? label;
  final int value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF000000 | value),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: colorHex(value),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: label ?? context.l10n.component_field_color,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
              LengthLimitingTextInputFormatter(7),
            ],
            validator: (input) => _parseHex(input) == null
                ? context.l10n.component_color_invalid
                : null,
            onChanged: (input) {
              final rgb = _parseHex(input);
              if (rgb != null) onChanged(rgb);
            },
          ),
        ),
      ],
    );
  }

  static int? _parseHex(String? input) {
    final hex = input?.replaceFirst('#', '');
    if (hex == null || hex.length != 6) return null;
    return int.tryParse(hex, radix: 16);
  }
}

class _ListField extends StatelessWidget {
  const _ListField({
    required this.label,
    required this.schema,
    required this.values,
    required this.onChanged,
  });

  final String? label;
  final ListSchema schema;
  final List<Object?> values;
  final ValueChanged<Object?> onChanged;

  bool get _full =>
      schema.maxLength != null && values.length >= schema.maxLength!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Section(
      title:
          '${label ?? context.l10n.component_field_entries} (${values.length})',
      trailing: IconButton(
        tooltip: context.l10n.component_entry_add,
        icon: const Icon(Icons.add),
        onPressed: _full
            ? null
            : () => onChanged([...values, initialValue(schema.element)]),
      ),
      children: [
        if (values.isEmpty)
          Text(
            context.l10n.component_entries_empty,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        for (var i = 0; i < values.length; i++)
          Row(
            // Stable while typing; a changed length rebuilds the rows, so a
            // removed entry doesn't leave its text in the next field.
            key: ValueKey('$i/${values.length}'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SchemaField(
                  schema: schema.element,
                  value: values[i],
                  onChanged: (value) => onChanged([...values]..[i] = value),
                ),
              ),
              IconButton(
                tooltip: context.l10n.component_entry_remove,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => onChanged([...values]..removeAt(i)),
              ),
            ],
          ),
      ],
    );
  }
}

class _ObjectField extends StatelessWidget {
  const _ObjectField({
    required this.label,
    required this.schema,
    required this.values,
    required this.onChanged,
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
    final fields = [
      for (final entry in schema.fields.entries)
        _buildField(context.l10n, entry.key, entry.value),
    ];
    final label = this.label;
    // The top level object of a component needs no frame, the dialog is one.
    if (label == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _spaced(fields),
      );
    }
    return _Section(title: label, children: fields);
  }

  Widget _buildField(AppLocalizations l10n, String name, ComponentField field) {
    final included = values.containsKey(name);
    final input = SchemaField(
      schema: field.schema,
      value: values[name],
      label: field.label,
      onChanged: (value) => _set(name, value),
    );
    if (!field.optional) return input;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(l10n.component_field_optional(field.label)),
          value: included,
          onChanged: (include) => _toggle(name, field, include ?? false),
        ),
        // The floating label of the outlined input needs room below the box.
        if (included) ...[verticalSpacing10, input],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.trailing});

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              ?trailing,
            ],
          ),
          ..._spaced(children),
        ],
      ),
    );
  }
}

List<Widget> _spaced(List<Widget> children) => [
  for (var i = 0; i < children.length; i++) ...[
    if (i > 0) verticalSpacing10,
    children[i],
  ],
];
