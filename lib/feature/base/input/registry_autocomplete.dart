import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/input/material_autocomplete.dart';
import 'package:vulpes_data/banner.dart';
import 'package:vulpes_data/damage.dart';
import 'package:vulpes_data/item.dart';
import 'package:vulpes_data/painting.dart';
import 'package:vulpes_data/sound.dart';

/// The most suggestions shown under a field at once.
const int maxRegistrySuggestions = 8;

/// The entries of the registries vulpes_data knows, by the name a
/// `KeySchema` gives its registry.
// TODO: use the lookup of vulpes_data once the CLI generates one.
const Map<String, List<Keyed>> _registries = {
  'sound_event': [
    ...AmbientSound.values,
    ...BlockSound.values,
    ...EntitySound.values,
    ...ItemSound.values,
    ...MusicSound.values,
  ],
  'damage_type': DamageType.values,
  'trim_material': TrimMaterial.values,
  'trim_pattern': TrimPattern.values,
  'banner_pattern': BannerPattern.values,
  'instrument': Instrument.values,
  'jukebox_song': JukeboxSong.values,
  'painting_variant': PaintingVariant.values,
};

/// One search per registry, built on first use and shared by every field.
final Map<String, _RegistrySearch> _searches = {};

_RegistrySearch? _searchOf(String registry) => switch (_registries[registry]) {
  null => null,
  final entries => _searches.putIfAbsent(
    registry,
    () => _RegistrySearch(entries),
  ),
};

/// Whether the entries of [registry] are known, so a field can suggest them.
bool suggestsRegistry(String registry) => _registries.containsKey(registry);

/// The entries of [registry] matching [query], at most
/// [maxRegistrySuggestions]. An empty query suggests nothing.
List<Keyed> suggestRegistry(String registry, String query) =>
    _searchOf(registry)?.search(query) ?? const [];

/// A plain scan over the name and the key of each entry: every word of the
/// query has to occur, entries whose name or key starts with the query come
/// first. Even the sounds, the largest registry, are scanned within a fraction
/// of a millisecond, so no index is needed.
class _RegistrySearch {
  _RegistrySearch(this._entries)
    : _paths = [
        for (final entry in _entries)
          entry.key.substring(entry.key.indexOf(':') + 1),
      ],
      _names = [for (final entry in _entries) entry.displayName.toLowerCase()];

  final List<Keyed> _entries;

  /// The key of the entry at the same index without its namespace, e.g.
  /// `entity.zombie.hurt`.
  final List<String> _paths;

  /// The lowercase name of the entry at the same index, e.g. `zombie hurt`.
  final List<String> _names;

  List<Keyed> search(String query) {
    final words = query.toLowerCase().split(RegExp(r'[\s:_.]+'))
      ..removeWhere((word) => word.isEmpty || word == 'minecraft');
    if (words.isEmpty) return const [];
    final leading = <Keyed>[];
    final others = <Keyed>[];
    for (var i = 0; i < _entries.length; i++) {
      final path = _paths[i];
      final name = _names[i];
      if (!words.every((word) => path.contains(word) || name.contains(word))) {
        continue;
      }
      final starts =
          path.startsWith(words.first) || name.startsWith(words.first);
      (starts ? leading : others).add(_entries[i]);
      if (leading.length == maxRegistrySuggestions) break;
    }
    return [...leading, ...others].take(maxRegistrySuggestions).toList();
  }
}

/// A free text field for a key of [registry] that suggests its entries while
/// typing. Like [MaterialAutocomplete], the suggestions are only a shortcut:
/// anything typed stays valid, e.g. an entry of a data pack.
class RegistryAutocomplete extends StatelessWidget {
  const RegistryAutocomplete({
    required this.registry,
    required this.fieldBuilder,
    required this.onSelected,
    this.initialValue = '',
    @visibleForTesting this.skipSuggestions,
    super.key,
  });

  final String registry;

  /// Builds the input, see [MaterialAutocomplete.fieldBuilder].
  final Widget Function(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  )
  fieldBuilder;
  final void Function(String key) onSelected;
  final String initialValue;

  /// See [MaterialAutocomplete.skipSuggestions].
  final bool? skipSuggestions;

  bool get _skipSuggestions =>
      skipSuggestions ?? (kIsWeb && SemanticsBinding.instance.semanticsEnabled);

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Keyed>(
      initialValue: TextEditingValue(text: initialValue),
      displayStringForOption: (entry) => entry.key,
      optionsBuilder: (value) =>
          _skipSuggestions ? const [] : suggestRegistry(registry, value.text),
      onSelected: (entry) => onSelected(entry.key),
      fieldViewBuilder: fieldBuilder,
      optionsViewBuilder: (context, onSelected, options) =>
          KeyedSuggestionList(options: options, onSelected: onSelected),
    );
  }
}
