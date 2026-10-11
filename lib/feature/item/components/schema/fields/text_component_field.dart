import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/minimessage_editor.dart';
import 'package:stelaris/util/component_context.dart';
import 'package:stelaris/util/minimessage_json.dart';

/// The input for a text component. It is edited as MiniMessage and stored in
/// the vanilla JSON format, like every component value.
///
/// The field keeps the MiniMessage it was given, a round trip through JSON
/// on every keystroke would rewrite it under the caret, e.g. `red` to
/// `#ff5555` in a gradient.
class TextComponentField extends StatefulWidget {
  const TextComponentField({
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  /// The text component, a string, an object or a list.
  final Object? value;
  final ValueChanged<Object?> onChanged;
  final String? label;

  @override
  State<TextComponentField> createState() => _TextComponentFieldState();
}

class _TextComponentFieldState extends State<TextComponentField> {
  late String _text;

  /// The JSON last handed out, to tell it from a new value from outside.
  late String _reported;

  @override
  void initState() {
    super.initState();
    _text = MiniMessageJson.decode(widget.value);
    _reported = jsonEncode(widget.value);
  }

  @override
  void didUpdateWidget(TextComponentField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final value = jsonEncode(widget.value);
    if (value != _reported) {
      _reported = value;
      _text = MiniMessageJson.decode(widget.value);
    }
  }

  void _changed(String text) {
    _text = text;
    final component = MiniMessageJson.encode(text);
    _reported = jsonEncode(component);
    widget.onChanged(component);
  }

  @override
  Widget build(BuildContext context) {
    return MiniMessageEditor(
      value: _text,
      onChanged: _changed,
      label: widget.label,
      // Book pages need their line breaks, a dedicated book editor will
      // take them over.
      multiline: true,
      // The context where it is shown is not known here, names and most
      // other texts are white.
      componentContext: ComponentContext.itemName,
    );
  }
}
