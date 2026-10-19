import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/actions/theme_actions.dart';
import 'package:stelaris/api/state/app_state.dart';

void main() {
  Store<AppState> buildStore({AppState? initialState}) =>
      Store<AppState>(initialState: initialState ?? const AppState());

  group('UpdateThemeSettingsAction', () {
    test(
      'replaces themeSettings and leaves the rest of the state untouched',
      () {
        final store = buildStore(
          initialState: const AppState().copyWith(openNavigation: false),
        );
        final newSettings = store.state.themeSettings.copyWith(fontScale: 1.2);

        store.dispatchSync(UpdateThemeSettingsAction(newSettings));

        expect(store.state.themeSettings, newSettings);
        expect(store.state.openNavigation, isFalse);
      },
    );
  });

  group('ToggleSystemThemeAction', () {

    test('seeds isDarkMode from the live system brightness so turning '
        '"follow system" off does not snap back to a stale manual value', () {
      final store = buildStore(
        initialState: const AppState().copyWith(
          themeSettings: const AppState().themeSettings.copyWith(
            useSystemTheme: true,
            isDarkMode: false, // stale manual value
          ),
        ),
      );

      // The system is actually in dark mode while useSystemTheme is on.
      store.dispatchSync(ToggleSystemThemeAction(true));

      expect(store.state.themeSettings.useSystemTheme, isFalse);
      expect(store.state.themeSettings.isDarkMode, isTrue);
    });

    test('also syncs isDarkMode when turning "follow system" on', () {
      final store = buildStore(
        initialState: const AppState().copyWith(
          themeSettings: const AppState().themeSettings.copyWith(
            useSystemTheme: false,
            isDarkMode: true,
          ),
        ),
      );

      // The system is actually light while the user was manually in dark mode.
      store.dispatchSync(ToggleSystemThemeAction(false));

      expect(store.state.themeSettings.useSystemTheme, isTrue);
      expect(store.state.themeSettings.isDarkMode, isFalse);
    });
  });

  group('ToggleDarkModeAction', () {
    test('flips isDarkMode', () {
      final store = buildStore(
        initialState: const AppState().copyWith(
          themeSettings: const AppState().themeSettings.copyWith(
            isDarkMode: false,
          ),
        ),
      );

      store.dispatchSync(ToggleDarkModeAction());

      expect(store.state.themeSettings.isDarkMode, isTrue);
    });

    test('disables useSystemTheme so the manual choice sticks', () {
      final store = buildStore(
        initialState: const AppState().copyWith(
          themeSettings: const AppState().themeSettings.copyWith(
            useSystemTheme: true,
          ),
        ),
      );

      store.dispatchSync(ToggleDarkModeAction());

      expect(store.state.themeSettings.useSystemTheme, isFalse);
    });
  });

  group('UpdatePrimaryColorAction', () {
    test('updates only the primary color', () {
      final store = buildStore();
      final accentBefore = store.state.themeSettings.accentColor;

      store.dispatchSync(UpdatePrimaryColorAction(Colors.red));

      expect(store.state.themeSettings.primaryColor, Colors.red);
      expect(store.state.themeSettings.accentColor, accentBefore);
    });
  });

  group('SetThemeModeAction', () {
    AppState stateWith({required bool useSystemTheme, required bool isDark}) =>
        const AppState().copyWith(
          themeSettings: const AppState().themeSettings.copyWith(
            useSystemTheme: useSystemTheme,
            isDarkMode: isDark,
          ),
        );

    test('dark turns system off and dark on', () {
      final store = buildStore(
        initialState: stateWith(useSystemTheme: true, isDark: false),
      );

      store.dispatchSync(SetThemeModeAction(ThemeMode.dark));

      expect(store.state.themeSettings.useSystemTheme, isFalse);
      expect(store.state.themeSettings.isDarkMode, isTrue);
    });

    test('light turns system off and dark off', () {
      final store = buildStore(
        initialState: stateWith(useSystemTheme: true, isDark: true),
      );

      store.dispatchSync(SetThemeModeAction(ThemeMode.light));

      expect(store.state.themeSettings.useSystemTheme, isFalse);
      expect(store.state.themeSettings.isDarkMode, isFalse);
    });

    test('system turns system on and keeps the manual choice', () {
      final store = buildStore(
        initialState: stateWith(useSystemTheme: false, isDark: true),
      );

      store.dispatchSync(SetThemeModeAction(ThemeMode.system));

      expect(store.state.themeSettings.useSystemTheme, isTrue);
      expect(store.state.themeSettings.isDarkMode, isTrue);
    });

    test('leaves the colors and the font scale alone', () {
      final store = buildStore(
        initialState: const AppState().copyWith(
          themeSettings: const AppState().themeSettings.copyWith(
            primaryColor: Colors.red,
            fontScale: 1.2,
          ),
        ),
      );

      store.dispatchSync(SetThemeModeAction(ThemeMode.dark));

      expect(store.state.themeSettings.primaryColor, Colors.red);
      expect(store.state.themeSettings.fontScale, 1.2);
    });
  });

  group('ResetAppearanceSettingsAction', () {
    final changed = const AppState().themeSettings.copyWith(
      useSystemTheme: false,
      isDarkMode: true,
      primaryColor: Colors.red,
      accentColor: Colors.orange,
      fontScale: 1.4,
    );

    test('restores the mode and both colors', () {
      final store = buildStore(
        initialState: const AppState().copyWith(themeSettings: changed),
      );

      store.dispatchSync(ResetAppearanceSettingsAction());

      final defaults = ThemeSettings.defaultSettings();
      expect(store.state.themeSettings.useSystemTheme, defaults.useSystemTheme);
      expect(store.state.themeSettings.isDarkMode, defaults.isDarkMode);
      expect(store.state.themeSettings.primaryColor, defaults.primaryColor);
      expect(store.state.themeSettings.accentColor, defaults.accentColor);
    });

    test('keeps the font scale', () {
      final store = buildStore(
        initialState: const AppState().copyWith(themeSettings: changed),
      );

      store.dispatchSync(ResetAppearanceSettingsAction());

      expect(store.state.themeSettings.fontScale, 1.4);
    });
  });

  group('ResetFontScaleAction', () {
    final changed = const AppState().themeSettings.copyWith(
      useSystemTheme: false,
      isDarkMode: true,
      primaryColor: Colors.red,
      fontScale: 1.4,
    );

    test('restores the font scale', () {
      final store = buildStore(
        initialState: const AppState().copyWith(themeSettings: changed),
      );

      store.dispatchSync(ResetFontScaleAction());

      expect(
        store.state.themeSettings.fontScale,
        ThemeSettings.defaultSettings().fontScale,
      );
    });

    test('keeps the mode and the colors', () {
      final store = buildStore(
        initialState: const AppState().copyWith(themeSettings: changed),
      );

      store.dispatchSync(ResetFontScaleAction());

      expect(store.state.themeSettings.useSystemTheme, isFalse);
      expect(store.state.themeSettings.isDarkMode, isTrue);
      expect(store.state.themeSettings.primaryColor, Colors.red);
    });
  });

  group('UpdateFontScaleAction', () {
    test('updates only the font scale', () {
      final store = buildStore();
      final primaryBefore = store.state.themeSettings.primaryColor;

      store.dispatchSync(UpdateFontScaleAction(1.4));

      expect(store.state.themeSettings.fontScale, 1.4);
      expect(store.state.themeSettings.primaryColor, primaryBefore);
    });
  });
}
