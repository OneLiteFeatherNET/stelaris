import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_config.dart';
import 'package:stelaris/auth/auth_sessions.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/routes.dart';

AuthConfig get someProvider => AuthConfig(
  issuer: Uri.parse('https://idp.invalid/realms/stelaris'),
  clientId: 'stelaris-ui',
  scopes: const ['openid'],
  roleClaims: AuthConfig.defaultRoleClaimsFor('stelaris-ui'),
  roleClaimsSource: AuthConfig.defaultRoleClaimsSource,
);

/// A router carrying the composed guard, so the ordering between the two is
/// what is under test rather than either one alone.
GoRouter routerAt(String location) => GoRouter(
  initialLocation: location,
  redirect: appRedirect,
  routes: [
    GoRoute(
      path: '/items/detail',
      builder: (context, state) => const Scaffold(body: Text('item detail')),
    ),
    GoRoute(
      path: projectSelectionRoute,
      builder: (context, state) => const Scaffold(body: Text('projects')),
    ),
    GoRoute(
      path: signInRoute,
      builder: (context, state) => Scaffold(
        body: Text('sign in from ${state.uri.queryParameters['from']}'),
      ),
    ),
  ],
);

Future<void> pumpAt(WidgetTester tester, String location, {AppState? state}) =>
    tester.pumpWidget(
      StoreProvider<AppState>(
        store: Store<AppState>(initialState: state ?? const AppState()),
        child: MaterialApp.router(
          routerConfig: routerAt(location),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

void main() {
  tearDown(AuthSessions.reset);

  group('with no identity provider configured', () {
    setUp(AuthSessions.reset);

    testWidgets('nothing is guarded', (tester) async {
      // The rollout gate at the routing layer: a deployment that has not opted
      // in must reach its pages exactly as before.
      await pumpAt(tester, '/items/detail');
      await tester.pumpAndSettle();

      expect(find.text('item detail'), findsNothing);
      // Redirected by the project guard alone, which is the old behaviour.
      expect(find.text('projects'), findsOneWidget);
      expect(find.textContaining('sign in'), findsNothing);
    });
  });

  group('with a provider configured and nobody signed in', () {
    setUp(() async {
      AuthSessions.reset();
      // init() cannot reach the invalid issuer, which leaves the session
      // unavailable - and unavailable is the state the sign-in page explains
      // rather than one the guard redirects away from.
      await AuthSessions.start(
        baseHref: Uri.parse('https://stelaris.example/'),
        config: someProvider,
      );
    });

    testWidgets('a deep link is sent to sign in, not into the app',
        (tester) async {
      await pumpAt(tester, '/items/detail');
      await tester.pumpAndSettle();

      expect(find.text('item detail'), findsNothing);
      expect(find.textContaining('sign in'), findsOneWidget);
    });

    testWidgets('the route that was asked for is carried along',
        (tester) async {
      // Without this, signing in from a deep link lands on a default page and
      // the link the person followed is simply lost.
      await pumpAt(tester, '/items/detail');
      await tester.pumpAndSettle();

      expect(find.text('sign in from /items/detail'), findsOneWidget);
    });

    testWidgets('authentication is decided before project selection',
        (tester) async {
      // Order matters: the project guard would otherwise rewrite the location
      // to /projects first, and the route the person asked for would be gone
      // by the time sign-in remembered anything.
      await pumpAt(tester, '/items/detail');
      await tester.pumpAndSettle();

      expect(find.text('projects'), findsNothing);
      expect(find.text('sign in from /items/detail'), findsOneWidget);
    });

    testWidgets('an unreachable provider still guards, and says so on the page',
        (tester) async {
      // A provider that cannot be reached must not degrade into a deployment
      // without authentication. The sign-in page explains it; the guard still
      // guards.
      await pumpAt(tester, '/items/detail');
      await tester.pumpAndSettle();

      expect(find.textContaining('sign in'), findsOneWidget);
    });

    testWidgets('the sign-in route itself is not redirected', (tester) async {
      await pumpAt(tester, signInRoute);
      await tester.pumpAndSettle();

      expect(find.textContaining('sign in'), findsOneWidget);
    });
  });

  group('the guard itself', () {
    test('has no opinion without a session', () {
      AuthSessions.reset();

      expect(
        authRedirect(_FakeContext(), _fakeState('/items')),
        isNull,
      );
    });
  });
}

/// The guard never touches either argument when there is no session, which is
/// what lets these two be stubs.
class _FakeContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

GoRouterState _fakeState(String location) => _FakeState(location);

class _FakeState implements GoRouterState {
  _FakeState(this.matchedLocation);

  @override
  final String matchedLocation;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
