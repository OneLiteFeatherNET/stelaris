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
    this.action,
    super.key,
  });

  final String? label;
  final ListSchema schema;
  final List<Object?> values;
  final ValueChanged<Object?> onChanged;

  /// Shown in the header before the add button, e.g. to switch the input.
  final Widget? action;

  bool get _full =>
      schema.maxLength != null && values.length >= schema.maxLength!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registry = switch (schema.element) {
      KeySchema(:final registry) => registry,
      _ => null,
    };
    return SchemaSection(
      title:
          '${label ?? context.l10n.component_field_entries} (${values.length})',
      subtitle: registry == null
          ? null
          : context.l10n.component_key_helper(registry),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?action,
          IconButton(
            tooltip: context.l10n.component_entry_add,
            icon: const Icon(Icons.add),
            onPressed: _full
                ? null
                : () => onChanged([...values, initialValue(schema.element)]),
          ),
        ],
      ),
      children: [
        if (values.isEmpty)
          Text(
            context.l10n.component_entries_empty,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        for (var i = 0; i < values.length; i++) _buildEntry(context, i),
      ],
    );
  }

  Widget _buildEntry(BuildContext context, int i) {
    // Stable while typing; a changed length rebuilds the entries, so a
    // removed entry doesn't leave its text in the next field.
    final key = ValueKey('$i/${values.length}');
    final remove = IconButton(
      tooltip: context.l10n.component_entry_remove,
      icon: const Icon(Icons.remove_circle_outline),
      onPressed: () => onChanged([...values]..removeAt(i)),
    );
    final inline = SchemaField.takesSuffix(schema.element);
    final field = SchemaField(
      key: inline ? key : null,
      schema: schema.element,
      value: values[i],
      registryHint: false,
      // Inside a single line input the button stays centered on it, also
      // while an error is shown below.
      suffix: inline ? remove : null,
      onChanged: (value) => onChanged([...values]..[i] = value),
    );
    if (inline) return field;
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: field),
        remove,
      ],
    );
  }
}
