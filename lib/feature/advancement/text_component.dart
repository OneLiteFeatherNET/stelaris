import 'dart:convert';

/// Helpers for the title and description of an advancement, which the backend
/// stores as vanilla JSON text components.
///
/// The form edits them as plain text. A component that is an object keeps its
/// other keys (e.g. `color`) when its text is changed.

/// Returns the plain text of the [component], or the raw value if it is not
/// a text component.
String plainTextOf(String? component) {
  if (component == null || component.isEmpty) return '';
  final Object? decoded;
  try {
    decoded = jsonDecode(component);
  } on FormatException {
    return component;
  }
  return switch (decoded) {
    final String text => text,
    {'text': final String text} => text,
    _ => component,
  };
}

/// Returns the text component for the [text], based on the [previous]
/// component, or null if the [text] is empty.
String? textComponentOf(String text, {String? previous}) {
  if (text.isEmpty) return null;
  if (previous != null && previous.isNotEmpty) {
    try {
      final Object? decoded = jsonDecode(previous);
      if (decoded is Map<String, dynamic> && decoded['text'] is String) {
        return jsonEncode({...decoded, 'text': text});
      }
    } on FormatException {
      // Not a component, so it is replaced by a plain one.
    }
  }
  return jsonEncode(text);
}
