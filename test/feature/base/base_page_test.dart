import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/base_page.dart';
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
  });
}
