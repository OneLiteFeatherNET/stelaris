import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';

/// Factory class for building Material 3 themes and scaling typographies.
abstract final class AppTheme {
  static final Typography _typography = Typography.material2021();

  static final TextTheme _baseLightText = _typography.black.merge(
    _typography.englishLike,
  );

  static final TextTheme _baseDarkText = _typography.white.merge(
    _typography.englishLike,
  );

  /// Builds the Material 3 light [ThemeData] configured according to [settings].
  static ThemeData buildLight(ThemeSettings settings) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: settings.primaryColor,
      brightness: Brightness.light,
      secondary: settings.accentColor,
    );

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: scaleTextTheme(_baseLightText, settings.fontScale),
    );
  }

  /// Builds the Material 3 dark [ThemeData] configured according to [settings].
  static ThemeData buildDark(ThemeSettings settings) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: settings.primaryColor,
      brightness: Brightness.dark,
      secondary: settings.accentColor,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: scaleTextTheme(_baseDarkText, settings.fontScale),
    );
  }

  /// Scales the [fontSize] of all text styles in [base] by [factor].
  static TextTheme scaleTextTheme(TextTheme base, double factor) {
    if (factor == 1.0) return base;

    TextStyle? scale(TextStyle? style) {
      if (style == null) return null;
      final size = style.fontSize;
      if (size == null) return style;
      return style.copyWith(fontSize: size * factor);
    }

    return base.copyWith(
      displayLarge: scale(base.displayLarge),
      displayMedium: scale(base.displayMedium),
      displaySmall: scale(base.displaySmall),
      headlineLarge: scale(base.headlineLarge),
      headlineMedium: scale(base.headlineMedium),
      headlineSmall: scale(base.headlineSmall),
      titleLarge: scale(base.titleLarge),
      titleMedium: scale(base.titleMedium),
      titleSmall: scale(base.titleSmall),
      bodyLarge: scale(base.bodyLarge),
      bodyMedium: scale(base.bodyMedium),
      bodySmall: scale(base.bodySmall),
      labelLarge: scale(base.labelLarge),
      labelMedium: scale(base.labelMedium),
      labelSmall: scale(base.labelSmall),
    );
  }
}
