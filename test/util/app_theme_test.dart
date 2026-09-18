import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/util/app_theme.dart';

void main() {
  group('AppTheme Unit Tests', () {
    test('buildLight creates a valid Material 3 light ThemeData', () {
      final settings = ThemeSettings.defaultSettings();
      final theme = AppTheme.buildLight(settings);

      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary.toARGB32(), isNotNull);
      expect(theme.textTheme.titleLarge?.fontSize, isNotNull);
      expect(theme.textTheme.bodyMedium?.fontSize, isNotNull);

      // Light theme text must be dark-colored to stay readable on a light surface.
      expect(theme.textTheme.bodyMedium?.color, isNotNull);
      expect(theme.textTheme.bodyMedium!.color!.computeLuminance(), lessThan(0.5));
    });

    test('buildDark creates a valid Material 3 dark ThemeData', () {
      final settings = ThemeSettings.defaultSettings().copyWith(
        isDarkMode: true,
      );
      final theme = AppTheme.buildDark(settings);

      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.brightness, Brightness.dark);
      expect(theme.textTheme.titleLarge?.fontSize, isNotNull);
      expect(theme.textTheme.bodyMedium?.fontSize, isNotNull);

      // Dark theme text must be light-colored to stay readable on a dark surface.
      expect(theme.textTheme.bodyMedium?.color, isNotNull);
      expect(theme.textTheme.bodyMedium!.color!.computeLuminance(), greaterThan(0.5));
    });

    test('scaleTextTheme scales all font sizes proportionally', () {
      final baseTheme = AppTheme.buildLight(ThemeSettings.defaultSettings())
          .textTheme;
      final defaultTitle = baseTheme.titleLarge?.fontSize;
      final defaultBody = baseTheme.bodyMedium?.fontSize;

      expect(defaultTitle, isNotNull);
      expect(defaultBody, isNotNull);

      final scaled = AppTheme.scaleTextTheme(baseTheme, 1.5);
      expect(scaled.titleLarge?.fontSize, closeTo(defaultTitle! * 1.5, 0.001));
      expect(scaled.bodyMedium?.fontSize, closeTo(defaultBody! * 1.5, 0.001));
    });

    test('scaleTextTheme returns identical instance when factor is 1', () {
      final baseTheme = AppTheme.buildLight(ThemeSettings.defaultSettings())
          .textTheme;
      final result = AppTheme.scaleTextTheme(baseTheme, 1);
      expect(identical(result, baseTheme), isTrue);
    });
  });
}
