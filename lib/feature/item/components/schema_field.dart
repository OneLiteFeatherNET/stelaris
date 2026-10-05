import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
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
String summarize(ComponentSchema schema, Object? value) => switch (schema) {
  UnitSchema() => 'Set',
  ColorSchema() when value is int => colorHex(value),
  ListSchema() when value is List => '${value.length} entries',
  ObjectSchema(:final fields) when value is Map =>
    value.entries
        .map((e) {
          final field = fields[e.key];
          final text = field == null
              ? '${e.value}'
              : summarize(field.schema, e.value);
          return '${field?.label ?? e.key}: $text';
        })
        .join(', '),
  UnsupportedSchema() => 'Not editable yet',
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
        title: Text(label ?? 'Enabled'),
        value: value as bool? ?? false,
        onChanged: onChanged,
      ),
      UnitSchema() => const _Hint(
        'This component has no value. Adding it to the item is enough.',
      ),
      StringSchema() || TextSchema() => TextFormField(
        initialValue: value as String? ?? '',
        decoration: InputDecoration(labelText: label),
        maxLines: schema is TextSchema ? null : 1,
        onChanged: onChanged,
      ),
      KeySchema(:final registry) => TextFormField(
        initialValue: value as String? ?? '',
        decoration: InputDecoration(
          labelText: label,
          hintText: 'minecraft:…',
          helperText: registry == null
              ? null
              : 'Key from the $registry registry',
        ),
        // Shown only when the field is required or switched on, so it always
        // needs a key: the codecs can't read an empty one.
        validator: (text) => switch (text) {
          null || '' => 'A key is required',
          final key when !_keyPattern.hasMatch(key) =>
            'Expected a key like minecraft:stone',
          _ => null,
        },
        onChanged: onChanged,
      ),
      EnumSchema(:final values) => DropdownButtonFormField<String>(
        initialValue: value as String?,
        decoration: InputDecoration(labelText: label),
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
      ListSchema() => _ListField(
        label: label,
        schema: schema,
        values: (value as List?) ?? const [],
        onChanged: onChanged,
      ),
      ObjectSchema() => _ObjectField(
        label: label,
        schema: schema,
        values: (value as Map?)?.cast<String, Object?>() ?? const {},
        onChanged: onChanged,
      ),
      UnsupportedSchema(:final javaType) => _Hint(
        '${label == null ? '' : '$label: '}not editable yet ($javaType).',
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

  String? get _range => switch ((min, max)) {
    (null, null) => null,
    (final min?, null) => 'At least $min',
    (null, final max?) => 'At most $max',
    (final min?, final max?) => 'Between $min and $max',
  };

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: text,
      decoration: InputDecoration(labelText: label, helperText: _range),
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
        if (input == null || input.isEmpty) return 'A value is required';
        final number = parse(input);
        if (number == null) return 'Not a number';
        if (min != null && number < min!) return _range;
        if (max != null && number > max!) return _range;
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
            decoration: InputDecoration(labelText: label ?? 'Color'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
              LengthLimitingTextInputFormatter(7),
            ],
            validator: (input) =>
                _parseHex(input) == null ? 'Expected #RRGGBB' : null,
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
      title: '${label ?? 'Entries'} (${values.length})',
      trailing: IconButton(
        tooltip: 'Add entry',
        icon: const Icon(Icons.add),
        onPressed: _full
            ? null
            : () => onChanged([...values, initialValue(schema.element)]),
      ),
      children: [
        if (values.isEmpty)
          Text(
            'No entries',
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
                tooltip: 'Remove entry',
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
        _buildField(entry.key, entry.value),
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

  Widget _buildField(String name, ComponentField field) {
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
          title: Text('${field.label} (optional)'),
          value: included,
          onChanged: (include) => _toggle(name, field, include ?? false),
        ),
        if (included) input,
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
    if (i > 0) const SizedBox(height: 12),
    children[i],
  ],
];
