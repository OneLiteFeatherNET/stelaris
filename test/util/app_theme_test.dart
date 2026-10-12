import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/app_shapes.dart';
import 'package:stelaris/util/app_theme.dart';
import 'package:stelaris/api/state/app_state.dart';

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

  group('AppTheme shapes', () {
    BorderRadiusGeometry? radiusOf(ShapeBorder? shape) =>
        (shape as RoundedRectangleBorder?)?.borderRadius;

    for (final (name, theme) in [
      ('light', AppTheme.buildLight(ThemeSettings.defaultSettings())),
      ('dark', AppTheme.buildDark(ThemeSettings.defaultSettings())),
    ]) {
      test('the $name theme rounds dialogs on the m3 scale', () {
        expect(
          radiusOf(theme.dialogTheme.shape),
          BorderRadius.circular(AppShapes.extraLarge),
        );
        // A card shape would take the outline of outlined cards.
        expect(theme.cardTheme.shape, isNull);
      });

      testWidgets('the $name theme draws every card variant medium round', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: Column(
                children: [
                  Card(key: Key('elevated')),
                  Card.filled(key: Key('filled')),
                  Card.outlined(key: Key('outlined')),
                ],
              ),
            ),
          ),
        );

        RoundedRectangleBorder shapeOf(String key) =>
            tester
                    .widget<Material>(
                      find
                          .descendant(
                            of: find.byKey(Key(key)),
                            matching: find.byType(Material),
                          )
                          .first,
                    )
                    .shape!
                as RoundedRectangleBorder;

        for (final key in ['elevated', 'filled', 'outlined']) {
          expect(
            shapeOf(key).borderRadius,
            BorderRadius.circular(AppShapes.medium),
            reason: key,
          );
        }
        expect(shapeOf('outlined').side.color, theme.colorScheme.outlineVariant);
      });

      test('the $name theme outlines every field with one radius', () {
        final border = theme.inputDecorationTheme.border;
        expect(border, isA<OutlineInputBorder>());
        expect(
          (border! as OutlineInputBorder).borderRadius,
          AppShapes.fieldRadius,
        );
      });
    }

    testWidgets('the form dialog takes its corners from the theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildLight(ThemeSettings.defaultSettings()),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FormDialog(
              title: 'Title',
              actionLabel: 'Save',
              onSubmit: () {},
              content: const SizedBox(),
            ),
          ),
        ),
      );

      expect(tester.widget<Dialog>(find.byType(Dialog)).shape, isNull);
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(Dialog),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(
        radiusOf(material.shape),
        BorderRadius.circular(AppShapes.extraLarge),
      );
    });
  });

  testWidgets('a field without its own border gets the outline of the theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.buildLight(ThemeSettings.defaultSettings()),
        home: const Scaffold(
          body: TextField(decoration: InputDecoration(labelText: 'Name')),
        ),
      ),
    );

    // The field hands the decoration on with the defaults of the theme.
    final border = tester
        .widget<InputDecorator>(find.byType(InputDecorator))
        .decoration
        .border;
    expect(border, isA<OutlineInputBorder>());
    expect((border! as OutlineInputBorder).borderRadius, AppShapes.fieldRadius);
  });

  test('the default settings are the ones a fresh app starts with', () {
    expect(ThemeSettings.defaultSettings(), const AppState().themeSettings);
    expect(ThemeSettings.defaultSettings().primaryColor, Colors.blue);
  });
}
