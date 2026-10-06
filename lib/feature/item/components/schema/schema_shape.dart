import 'package:vulpes_data/component.dart';

/// The field of a list whose entries are objects with nothing but one list or
/// registry tag, like the block predicates of `minecraft:can_break`; null for
/// other lists.
///
/// Such a list is edited as the one inner value: an item matches if any entry
/// does, so the blocks of two entries do the same in a single one, and the
/// second level of entries only nested the dialog. Several entries can only be
/// joined while all of them hold a list, a tag can't be part of a list.
({String name, ComponentField field})? flattened(
  ListSchema schema,
  List<Object?> entries,
) => switch (schema.element) {
  ObjectSchema(:final fields)
      when fields.length == 1 &&
          switch (fields.values.single.schema) {
            ListSchema() => true,
            RegistryTagSchema() =>
              entries.length <= 1 ||
                  entries.every(
                    (entry) =>
                        entry is Map && entry[fields.keys.single] is List,
                  ),
            _ => false,
          } =>
    (name: fields.keys.single, field: fields.values.single),
  _ => null,
};

/// The inner values of all [entries] joined into one: a single tag stays the
/// tag, the lists are joined.
Object? unwrap(String name, List<Object?> entries) => switch (entries) {
  [final Map entry] when entry[name] is String => entry[name],
  _ => [
    for (final entry in entries)
      if (entry is Map && entry[name] is List) ...entry[name] as List,
  ],
};

/// The joined [value] as the single entry of a flattened list.
List<Object?> wrap(String name, Object? value) => [
  if (value is! List || value.isNotEmpty) {name: value},
];
