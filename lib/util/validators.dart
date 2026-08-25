import 'package:stelaris/util/constants.dart';

typedef FormValidator<T> = String? Function(T? value);

/// Utility class providing reusable form validation rules.
class Validators {
  Validators._();

  /// Validates that a string is not null, empty or only whitespace.
  static FormValidator<String> required([String message = 'This field is required']) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  /// Validates that a string matches the given [regex].
  /// Empty/null values are skipped so they can be handled by [required] if needed.
  static FormValidator<String> pattern(RegExp regex, [String message = 'Invalid format']) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      if (!regex.hasMatch(value.trim())) {
        return message;
      }
      return null;
    };
  }

  /// Combines multiple [FormValidator]s in sequential order.
  /// Stops and returns the error of the first failing validator.
  static FormValidator<String> compose(List<FormValidator<String>> validators) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Validates a Minecraft / Kyori Adventure key or namespace.
  ///
  /// Examples of valid keys: `my_project`, `minecraft:stone`, `custom:item/tool`
  static FormValidator<String> adventureKey({
    String requiredMessage = 'Key / Namespace is required',
    String invalidMessage = 'Invalid Adventure key (e.g. "my_project" or "custom:my_project")',
    bool detailed = true,
  }) {
    if (!detailed) {
      return compose([
        required(requiredMessage),
        pattern(adventureKeyPattern, invalidMessage),
      ]);
    }

    return (value) {
      if (value == null || value.trim().isEmpty) {
        return requiredMessage;
      }

      final text = value.trim();

      if (text.contains(RegExp(r'[A-Z]'))) {
        return 'Uppercase letters are not allowed in Adventure keys';
      }
      if (text.contains(' ')) {
        return 'Spaces are not allowed';
      }
      if (':'.allMatches(text).length > 1) {
        return 'Only one colon (:) is allowed for namespace:key';
      }
      if (text.contains('..')) {
        return 'Double dots (..) are not allowed';
      }
      if (text.contains(':')) {
        final parts = text.split(':');
        if (parts[0].contains('/')) {
          return 'Namespace cannot contain slashes (/)';
        }
      }
      if (!adventureKeyPattern.hasMatch(text)) {
        return invalidMessage;
      }

      return null;
    };
  }

  /// Validates only the namespace part of an Adventure key (the left part before the colon).
  /// Slashes (/), colons (:), double dots (..), uppercase letters, and spaces are not allowed.
  ///
  /// Examples of valid namespaces: `my_project`, `project-name`, `custom.addon_1`
  static FormValidator<String> adventureNamespace({
    String requiredMessage = 'Key / Namespace is required',
    String invalidMessage = 'Invalid namespace (only lowercase letters, numbers, [._-] allowed, e.g. "my_project")',
    bool detailed = true,
  }) {
    if (!detailed) {
      return compose([
        required(requiredMessage),
        pattern(adventureNamespacePattern, invalidMessage),
      ]);
    }

    return (value) {
      if (value == null || value.trim().isEmpty) {
        return requiredMessage;
      }

      final text = value.trim();

      if (text.contains('..')) {
        return 'Double dots (..) are not allowed';
      }
      if (text.contains(':')) {
        return 'Colons (:) are not allowed (only the namespace part, e.g. "my_project")';
      }
      if (text.contains('/')) {
        return 'Slashes (/) are not allowed in a namespace';
      }
      if (text.contains(RegExp(r'[A-Z]'))) {
        return 'Uppercase letters are not allowed';
      }
      if (text.contains(' ')) {
        return 'Spaces are not allowed';
      }
      if (!adventureNamespacePattern.hasMatch(text)) {
        return invalidMessage;
      }

      return null;
    };
  }
}
