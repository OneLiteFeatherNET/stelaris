import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/schema/fields/section.dart';
import 'package:stelaris/feature/item/components/schema/schema_field.dart';
import 'package:stelaris/feature/item/components/schema/schema_value.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/component.dart';

/// The fields of an object value; optional fields can be switched on and off.
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
    final fields = [
      for (final entry in schema.fields.entries)
        _buildField(context.l10n, entry.key, entry.value),
    ];
    final label = this.label;
    // The top level object of a component needs no frame, the dialog is one.
    if (label == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spaced(fields),
      );
    }
    return SchemaSection(title: label, children: fields);
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
