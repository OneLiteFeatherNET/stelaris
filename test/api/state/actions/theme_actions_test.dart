import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/theme_actions.dart';
import 'package:stelaris/api/state/app_state.dart';

void main() {
  Store<AppState> buildStore({AppState? initialState}) =>
      Store<AppState>(initialState: initialState ?? const AppState());

  group('UpdateThemeSettingsAction', () {
    test('replaces themeSettings and leaves the rest of the state untouched', () {
      final store = buildStore(
        initialState: const AppState().copyWith(openNavigation: false),
      );
      final newSettings = store.state.themeSettings.copyWith(fontScale: 1.2);

      store.dispatchSync(UpdateThemeSettingsAction(newSettings));

      expect(store.state.themeSettings, newSettings);
      expect(store.state.openNavigation, isFalse);
    });
  });

  group('ToggleSystemThemeAction', () {
    test('flips useSystemTheme from true to false', () {
      final store = buildStore(
        initialState: const AppState().copyWith(
          themeSettings: const AppState().themeSettings.copyWith(
            useSystemTheme: true,
          ),
        ),
      );

      store.dispatchSync(ToggleSystemThemeAction(false));

      expect(store.state.themeSettings.useSystemTheme, isFalse);
    });

    test('flips useSystemTheme from false to true', () {
      final store = buildStore(
        initialState: const AppState().copyWith(
          themeSettings: const AppState().themeSettings.copyWith(
            useSystemTheme: false,
          ),
        ),
      );

      store.dispatchSync(ToggleSystemThemeAction(true));

      expect(store.state.themeSettings.useSystemTheme, isTrue);
    });

    test(
      'seeds isDarkMode from the live system brightness so turning '
      '"follow system" off does not snap back to a stale manual value',
      () {
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
      },
    );

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

  group('UpdateAccentColorAction', () {
    test('updates only the accent color', () {
      final store = buildStore();
      final primaryBefore = store.state.themeSettings.primaryColor;

      store.dispatchSync(UpdateAccentColorAction(Colors.orange));

      expect(store.state.themeSettings.accentColor, Colors.orange);
      expect(store.state.themeSettings.primaryColor, primaryBefore);
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
