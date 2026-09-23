import 'package:async_redux/async_redux.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/project/project_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/base_page.dart';
import 'package:stelaris/feature/base/search/app_bar_search.dart';
import 'package:stelaris/feature/command_palette/command_palette.dart';
import 'package:stelaris/feature/command_palette/command_panel.dart';
import 'package:stelaris/feature/settings/settings_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('BasePage Widget Tests', () {
    testWidgets('redirects to /projects when selectedProject is null', (
      tester,
    ) async {
      final store = Store<AppState>(initialState: const AppState());

      var redirected = false;
      final testRouter = GoRouter(
        initialLocation: '/test',
        redirect: (context, state) {
          final appState = StoreProvider.state<AppState>(context);
          if (appState.selectedProject == null &&
              state.matchedLocation != '/projects') {
            redirected = true;
            return '/projects';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) =>
                const BasePage(child: Text('Protected Content')),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) =>
                const Scaffold(body: Text('Project Selection Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(redirected, isTrue);
      expect(find.text('Protected Content'), findsNothing);
      expect(find.text('Project Selection Page'), findsOneWidget);
    });

    testWidgets('renders child content when selectedProject is present', (
      tester,
    ) async {
      const project = Project(
        id: 'proj_1',
        key: 'test_key',
        displayName: 'Test Project',
      );
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedProject: project),
      );

      final testRouter = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) =>
                const BasePage(child: Text('Protected Content')),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) =>
                const Scaffold(body: Text('Project Selection Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp.router(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Protected Content'), findsOneWidget);
      expect(find.text('Test Project'), findsOneWidget);
    });

    testWidgets('switching sections gives the search a fresh field and drops '
        'a query still in the debounce', (tester) async {
      // Wide enough for the full search field instead of the compact icon.
      tester.view.physicalSize = const Size(1600, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const project = Project(
        id: 'proj_1',
        key: 'test_key',
        displayName: 'Test Project',
      );
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedProject: project),
      );
      final testRouter = GoRouter(
        initialLocation: '/items',
        routes: [
          ShellRoute(
            builder: (context, state, child) => BasePage(child: child),
            routes: [
              GoRoute(
                path: '/items',
                builder: (context, state) => const Text('Item List'),
              ),
              GoRoute(
                path: '/fonts',
                builder: (context, state) => const Text('Font List'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp.router(
            routerConfig: testRouter,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump(const Duration(milliseconds: 100));
      testRouter.go('/fonts');
      // The switch is built in the next frame, well within the debounce.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Font List'), findsOneWidget);
      expect(store.state.modelSearch.query, '');
      expect(find.text('abc'), findsNothing);
      expect(find.text('Search Fonts, or ? for more'), findsOneWidget);
    });
  });

  group('BasePage command palette shortcut', () {
    const project = Project(
      id: 'proj_1',
      key: 'test_key',
      displayName: 'Test Project',
    );

    /// The real shell: [BasePage] around a list page with a search bar, next
    /// to a project selection page outside the shell.
    Future<void> pumpShell(WidgetTester tester, {String at = '/items'}) async {
      final store = Store<AppState>(
        initialState: const AppState().copyWith(selectedProject: project),
      );
      final router = GoRouter(
        initialLocation: at,
        routes: [
          GoRoute(
            path: '/projects',
            builder: (context, state) =>
                const Scaffold(body: Text('Project Selection Page')),
          ),
          ShellRoute(
            builder: (context, state, child) => BasePage(child: child),
            routes: [
              GoRoute(
                path: '/items',
                builder: (context, state) =>
                    const SearchBar(key: Key('model-search')),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> pressCtrlK(WidgetTester tester) async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
    }

    EditableText searchField(WidgetTester tester) =>
        tester.widget<EditableText>(
          find.descendant(
            of: find.byKey(const Key('model-search')),
            matching: find.byType(EditableText),
          ),
        );

    testWidgets('a project switch keeps the shortcut and its actions', (
      tester,
    ) async {
      await pumpShell(tester);
      Map<Type, Action<Intent>> actions() => tester
          .widget<Actions>(
            find
                .descendant(
                  of: find.byType(CommandPaletteShortcuts),
                  matching: find.byType(Actions),
                )
                .first,
          )
          .actions;
      final before = actions();
      final store = StoreProvider.backdoorInheritedWidget<AppState>(
        tester.element(find.byType(BasePage)),
      );

      store.dispatch(
        SelectProjectAction(
          const Project(id: 'proj_2', key: 'other', displayName: 'Other'),
        ),
      );
      await tester.pumpAndSettle();

      expect(identical(actions(), before), isTrue);
      await pressCtrlK(tester);
      expect(find.byType(CommandPanel), findsOneWidget);
    });

    testWidgets('Ctrl+K opens the palette before anything was clicked', (
      tester,
    ) async {
      await pumpShell(tester);

      await pressCtrlK(tester);

      expect(find.byType(CommandPanel), findsOneWidget);
    });

    testWidgets('Ctrl+K opens it while the search bar has focus and leaves '
        'the search text alone', (tester) async {
      await pumpShell(tester);
      await tester.tap(find.byKey(const Key('model-search')));
      await tester.enterText(find.byKey(const Key('model-search')), 'sword');
      await tester.pumpAndSettle();
      expect(searchField(tester).focusNode.hasFocus, isTrue);

      await pressCtrlK(tester);

      expect(find.byType(CommandPanel), findsOneWidget);
      expect(searchField(tester).controller.text, 'sword');
    });

    testWidgets('Escape closes the dropdown and the app bar field keeps its '
        'focus', (tester) async {
      await pumpShell(tester);
      await tester.tap(find.byKey(const Key('model-search')));
      await tester.pumpAndSettle();
      await pressCtrlK(tester);
      expect(find.byType(CommandPanel), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(CommandPanel), findsNothing);
      final EditableText appBarField = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(AppBarSearch),
          matching: find.byType(EditableText),
        ),
      );
      expect(appBarField.focusNode.hasFocus, isTrue);
    });

    testWidgets('Ctrl+K does nothing on the project selection page', (
      tester,
    ) async {
      await pumpShell(tester, at: '/projects');

      await pressCtrlK(tester);

      expect(find.byType(CommandPanel), findsNothing);
    });

    testWidgets('Ctrl+K does nothing while the settings dialog is open', (
      tester,
    ) async {
      await pumpShell(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsDialog), findsOneWidget);

      await pressCtrlK(tester);

      expect(find.byType(CommandPanel), findsNothing);
    });
  });
}
