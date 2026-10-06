import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/components/schema/fields/section.dart';
import 'package:stelaris/feature/item/components/schema/schema_field.dart';
import 'package:stelaris/feature/item/components/schema/schema_value.dart';
import 'package:stelaris/util/l10n_ext.dart';
import 'package:vulpes_data/component.dart';

/// The entries of a list value, each edited through its own [SchemaField].
class ListField extends StatelessWidget {
  const ListField({
    required this.label,
    required this.schema,
    required this.values,
    required this.onChanged,
    super.key,
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
    return SchemaSection(
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
