import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';

typedef FormValidator<T> = String? Function(T? value);

/// Utility class providing reusable form validation rules.
///
/// Validators have no `BuildContext`, so the messages come in through the
/// [AppLocalizations] passed to them (usually `context.l10n`).
class Validators {
  Validators._();

  /// Validates that a string is not null, empty or only whitespace.
  static FormValidator<String> required(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  /// Validates that a string matches the given [regex].
  /// Empty/null values are skipped so they can be handled by [required] if needed.
  static FormValidator<String> pattern(RegExp regex, String message) {
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
  static FormValidator<String> adventureKey(
    AppLocalizations l10n, {
    bool detailed = true,
  }) {
    final requiredMessage = l10n.validation_namespace_required;
    final invalidMessage = l10n.validation_adventure_key_invalid;
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
        return l10n.validation_no_uppercase_key;
      }
      if (text.contains(' ')) {
        return l10n.validation_no_spaces;
      }
      if (':'.allMatches(text).length > 1) {
        return l10n.validation_one_colon;
      }
      if (text.contains('..')) {
        return l10n.validation_no_double_dots;
      }
      if (text.contains(':')) {
        final parts = text.split(':');
        if (parts[0].contains('/')) {
          return l10n.validation_namespace_slash_in_key;
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
  static FormValidator<String> adventureNamespace(
    AppLocalizations l10n, {
    bool detailed = true,
  }) {
    final requiredMessage = l10n.validation_namespace_required;
    final invalidMessage = l10n.validation_namespace_invalid;
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
        return l10n.validation_no_double_dots;
      }
      if (text.contains(':')) {
        return l10n.validation_namespace_no_colon;
      }
      if (text.contains('/')) {
        return l10n.validation_namespace_no_slash;
      }
      if (text.contains(RegExp(r'[A-Z]'))) {
        return l10n.validation_no_uppercase;
      }
      if (text.contains(' ')) {
        return l10n.validation_no_spaces;
      }
      if (!adventureNamespacePattern.hasMatch(text)) {
        return invalidMessage;
      }

      return null;
    };
  }

  /// Validates only the key/value part of an Adventure key (the right part after the colon).
  /// Slashes (/), underscores (_), hyphens (-), and dots (.) are allowed.
  /// Colons (:), double dots (..), uppercase letters, and spaces are not allowed.
  ///
  /// Examples of valid keys: `ruby_sword`, `item/weapon/sword`, `magic.wand`
  static FormValidator<String> adventureKeyPart(
    AppLocalizations l10n, {
    bool detailed = true,
  }) {
    final requiredMessage = l10n.validation_key_required;
    final invalidMessage = l10n.validation_key_part_invalid;
    if (!detailed) {
      return compose([
        required(requiredMessage),
        pattern(adventureKeyPartPattern, invalidMessage),
      ]);
    }

    return (value) {
      if (value == null || value.trim().isEmpty) {
        return requiredMessage;
      }

      final text = value.trim();

      if (text.contains('..')) {
        return l10n.validation_no_double_dots;
      }
      if (text.contains(':')) {
        return l10n.validation_key_part_no_colon;
      }
      if (text.contains(RegExp(r'[A-Z]'))) {
        return l10n.validation_no_uppercase;
      }
      if (text.contains(' ')) {
        return l10n.validation_no_spaces;
      }
      if (!adventureKeyPartPattern.hasMatch(text)) {
        return invalidMessage;
      }

      return null;
    };
  }

  /// Validates an enchantment level input against [maxLevel].
  /// When [unsafe] is true, the max-level constraint is skipped, but the level
  /// is still limited to [maxEnchantmentLevel] (the range of a short).
  static String? enchantmentLevel(
    AppLocalizations l10n, {
    required String? value,
    required int maxLevel,
    bool unsafe = false,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validation_level_required;
    }
    final level = int.tryParse(value);
    if (level == null) {
      return l10n.validation_number_invalid;
    }
    if (!unsafe && level > maxLevel) {
      return l10n.validation_maximum(maxLevel);
    }
    if (level > maxEnchantmentLevel) {
      return l10n.validation_maximum(maxEnchantmentLevel);
    }
    return null;
  }
}
