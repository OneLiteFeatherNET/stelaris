import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';

void main() {
  group('ThemeSettings.themeMode', () {
    test('is system while the app follows the platform', () {
      final settings = ThemeSettings.defaultSettings().copyWith(
        useSystemTheme: true,
        isDarkMode: true,
      );

      expect(settings.themeMode, ThemeMode.system);
    });

    test('is dark for a manual dark choice', () {
      final settings = ThemeSettings.defaultSettings().copyWith(
        useSystemTheme: false,
        isDarkMode: true,
      );

      expect(settings.themeMode, ThemeMode.dark);
    });

    test('is light for a manual light choice', () {
      final settings = ThemeSettings.defaultSettings().copyWith(
        useSystemTheme: false,
        isDarkMode: false,
      );

      expect(settings.themeMode, ThemeMode.light);
    });
  });
}
