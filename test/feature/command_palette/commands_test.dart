import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/command_palette/backend_command.dart';
import 'package:stelaris/feature/command_palette/command.dart';
import 'package:stelaris/feature/command_palette/command_registry.dart';
import 'package:stelaris/feature/command_palette/commands.dart';
import 'package:stelaris/l10n/app_localizations.dart';

List<String> _availableAt(String location) {
  final registry = CommandRegistry(pocCommands());
  return registry
      .available(CommandContext(state: const AppState(), location: location))
      .map((command) => command.id)
      .toList();
}

StelarisCommand _byId(String id) =>
    pocCommands().firstWhere((command) => command.id == id);

void main() {
  group('navigation commands', () {
    test('one per navigation entry, plus the project list', () {
      final ids = pocCommands().map((command) => command.id);
      for (final entry in NavigationEntry.values) {
        expect(ids, contains('nav.${entry.name}'));
      }
      expect(ids, contains('nav.projects'));
    });

    bool isCurrentAt(String id, String location) =>
        pocCommands()
            .firstWhere((command) => command.id == id)
            .isCurrent
            ?.call(
              CommandContext(state: const AppState(), location: location),
            ) ??
        false;

    test('the current page is offered and marked, the others are not', () {
      final available = _availableAt('/fonts');
      expect(available, containsAll(['nav.font', 'nav.items', 'nav.projects']));
      expect(isCurrentAt('nav.font', '/fonts'), isTrue);
      expect(isCurrentAt('nav.items', '/fonts'), isFalse);
      expect(isCurrentAt('nav.projects', '/fonts'), isFalse);
    });

    test("a detail page counts as its list's page", () {
      expect(_availableAt('/fonts/detail'), contains('nav.font'));
      expect(isCurrentAt('nav.font', '/fonts/detail'), isTrue);
      expect(isCurrentAt('nav.items', '/fonts/detail'), isFalse);
    });

    test('the marked entry uses the filled navigation icon', () {
      final font = pocCommands().firstWhere((c) => c.id == 'nav.font');
      expect(font.currentIcon, NavigationEntry.font.selected);
    });
  });

  group('reload current list', () {
    test('is available on each of the five list pages', () {
      for (final entry in NavigationEntry.values) {
        expect(
          _availableAt(entry.route),
          contains('backend.reload-list'),
          reason: entry.route,
        );
      }
    });

    test('is not available on a detail page', () {
      for (final entry in NavigationEntry.values) {
        expect(
          _availableAt('${entry.route}/detail'),
          isNot(contains('backend.reload-list')),
          reason: entry.route,
        );
      }
    });

    test('is not available anywhere else', () {
      expect(_availableAt('/projects'), isNot(contains('backend.reload-list')));
    });

    test('maps every list page to a refresh action', () {
      for (final entry in NavigationEntry.values) {
        expect(refreshActionFor(entry), isNotNull);
      }
    });
  });

  group('backend outcomes', () {
    test('branches reload fails when branches end up null', () {
      const before = AppState(branches: ['main']);
      expect(
        branchReloadOutcome(before, before.copyWith(branches: null)),
        BackendOutcome.failure,
      );
      expect(
        branchReloadOutcome(before, before.copyWith(branches: ['main', 'dev'])),
        BackendOutcome.success,
      );
    });

    test('an unchanged release model reads as neutral', () {
      const state = AppState();
      expect(releaseReloadOutcome(state, state), BackendOutcome.neutral);
    });
  });

  group('interface commands', () {
    testWidgets('toggle dark mode flips isDarkMode and stops following the '
        'system theme', (tester) async {
      final store = Store<AppState>(
        // Light, following the system - the defaults, spelled out.
        initialState: AppState(
          themeSettings: ThemeSettings.defaultSettings().copyWith(
            isDarkMode: false,
            useSystemTheme: true,
          ),
        ),
      );
      late BuildContext context;
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (c) {
                context = c;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await _byId('ui.toggle-dark-mode').run(context);
      await tester.pump();

      expect(store.state.themeSettings.isDarkMode, isTrue);
      expect(store.state.themeSettings.useSystemTheme, isFalse);
    });
  });
}
