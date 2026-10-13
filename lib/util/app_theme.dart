import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/util/app_shapes.dart';

/// Factory class for building Material 3 themes and scaling typographies.
abstract final class AppTheme {
  static final Typography _typography = Typography.material2021();

  static final TextTheme _baseLightText = _typography.englishLike.merge(
    _typography.black,
  );

  static final TextTheme _baseDarkText = _typography.englishLike.merge(
    _typography.white,
  );

  /// Builds the Material 3 light [ThemeData] configured according to [settings].
  static ThemeData buildLight(ThemeSettings settings) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: settings.primaryColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: scaleTextTheme(_baseLightText, settings.fontScale),
      dialogTheme: _dialogTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  /// Builds the Material 3 dark [ThemeData] configured according to [settings].
  static ThemeData buildDark(ThemeSettings settings) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: settings.primaryColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: scaleTextTheme(_baseDarkText, settings.fontScale),
      dialogTheme: _dialogTheme,
      inputDecorationTheme: _inputDecorationTheme,
    );
  }

  // Cards need no theme: Material 3 already rounds them by
  // [AppShapes.medium]. A shape here would also replace the one of an
  // outlined card, and with it its outline.

  static final DialogThemeData _dialogTheme = DialogThemeData(
    shape: AppShapes.rounded(AppShapes.extraLarge),
  );

  /// Every field is outlined. The states take their colors from the theme
  /// and their corners from here.
  static final InputDecorationThemeData _inputDecorationTheme =
      InputDecorationThemeData(border: AppShapes.fieldBorder());

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
