import 'package:flutter/widgets.dart';
import 'package:stelaris/util/key_from_name.dart';

/// Keeps [key] filled from [name] through [keyFromName], e.g. `my_sword` for
/// `My Sword`, until the key is typed by hand. The key [key] holds when this
/// is made counts as filled from the name, so a prefilled key follows too.
/// Clearing the key makes it follow the name again.
class KeyFollowsName {
  KeyFollowsName({required this.name, required this.key})
    : _lastName = name.text,
      _lastKey = key.text {
    name.addListener(_onNameChanged);
  }

  final TextEditingController name;
  final TextEditingController key;

  String _lastName;

  /// The key last filled in from the name.
  String _lastKey;

  void _onNameChanged() {
    // The listener also fires on cursor and selection changes.
    if (name.text == _lastName) return;
    _lastName = name.text;

    final current = key.text;
    if (current.isNotEmpty && current != _lastKey) return;
    _lastKey = keyFromName(name.text);
    if (current != _lastKey) key.text = _lastKey;
  }

  void dispose() => name.removeListener(_onNameChanged);
}
