import 'package:vulpes_data/component.dart';

/// The field of a list whose entries are objects with nothing but one list,
/// like the block predicates of `minecraft:can_break`; null for other lists.
///
/// Such a list is edited as the one inner list: an item matches if any entry
/// does, so the blocks of two entries do the same in a single one, and the
/// second level of entries only nested the dialog.
({String name, ComponentField field})? flattened(ListSchema schema) =>
    switch (schema.element) {
      ObjectSchema(:final fields)
          when fields.length == 1 &&
              fields.values.single.schema is ListSchema =>
        (name: fields.keys.single, field: fields.values.single),
      _ => null,
    };

/// The inner lists of all [entries] joined into one.
List<Object?> unwrap(String name, List<Object?> entries) => [
  for (final entry in entries)
    if (entry is Map && entry[name] is List) ...entry[name] as List,
];

/// The joined [values] as the single entry of a flattened list.
List<Object?> wrap(String name, List<Object?> values) => [
  if (values.isNotEmpty) {name: values},
];
