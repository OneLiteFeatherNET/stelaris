import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_state.dart';
import 'package:stelaris/auth/roles.dart';
import 'package:stelaris/feature/auth/role_gate.dart';
import 'package:stelaris/feature/auth/session_indicator.dart';
import 'package:stelaris/feature/auth/sign_in_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';

Future<void> pump(WidgetTester tester, Widget child, AuthState auth) =>
    tester.pumpWidget(
      StoreProvider<AppState>(
        store: Store<AppState>(initialState: AppState(auth: auth)),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    );

void main() {
  group('SignInPage', () {
    testWidgets('asks a signed-out visitor to sign in', (tester) async {
      await pump(
        tester,
        const SignInPage(),
        const AuthState(status: AuthStatus.signedOut),
      );

      expect(find.text('Sign in to continue.'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('says a session expired rather than showing a data error',
        (tester) async {
      // An expiry is not a failure of the thing the person was editing, and
      // presenting it as one sends them looking in the wrong place.
      await pump(
        tester,
        const SignInPage(),
        const AuthState(status: AuthStatus.expired),
      );

      expect(
        find.text('Your session expired. Sign in again to continue.'),
        findsOneWidget,
      );
      expect(find.text('Sign in to continue.'), findsNothing);
    });

    testWidgets('explains an unreachable provider and offers a retry',
        (tester) async {
      await pump(
        tester,
        const SignInPage(),
        const AuthState(status: AuthStatus.unavailable),
      );

      expect(
        find.textContaining('identity provider could not be reached'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
    });
  });

  group('SessionIndicator', () {
    testWidgets('shows nothing where no provider is configured',
        (tester) async {
      // An unauthenticated deployment's app bar has to look exactly as it did.
      await pump(
        tester,
        const Scaffold(body: SessionIndicator()),
        const AuthState.disabled(),
      );

      expect(find.byType(PopupMenuButton<void>), findsNothing);
    });

    testWidgets('shows nothing while nobody is signed in', (tester) async {
      await pump(
        tester,
        const Scaffold(body: SessionIndicator()),
        const AuthState(status: AuthStatus.signedOut),
      );

      expect(find.byType(PopupMenuButton<void>), findsNothing);
    });

    testWidgets('names the signed-in person and offers a way out',
        (tester) async {
      await pump(
        tester,
        const Scaffold(body: SessionIndicator()),
        const AuthState(
          status: AuthStatus.signedIn,
          displayName: 'Ada Lovelace',
          roles: {Roles.admin},
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<void>));
      await tester.pumpAndSettle();

      expect(find.text('Ada Lovelace'), findsOneWidget);
      expect(find.text(Roles.admin), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('does not turn a long role list into a wall', (tester) async {
      // Entra ID with the groups claim enabled emits one object id per group.
      // Listing them all pushes the sign-out item off the bottom of the menu.
      await pump(
        tester,
        const Scaffold(body: SessionIndicator()),
        AuthState(
          status: AuthStatus.signedIn,
          displayName: 'Ada',
          roles: {for (int i = 0; i < 30; i++) 'group-id-$i'},
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<void>));
      await tester.pumpAndSettle();

      expect(find.textContaining('and 27 more'), findsOneWidget);
      expect(find.textContaining('group-id-29'), findsNothing);
      // The thing the menu exists for is still reachable.
      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('names a short role list in full', (tester) async {
      await pump(
        tester,
        const Scaffold(body: SessionIndicator()),
        const AuthState(
          status: AuthStatus.signedIn,
          displayName: 'Ada',
          roles: {Roles.admin, Roles.editor},
        ),
      );

      await tester.tap(find.byType(PopupMenuButton<void>));
      await tester.pumpAndSettle();

      expect(find.textContaining(Roles.admin), findsOneWidget);
      expect(find.textContaining('more'), findsNothing);
    });

    testWidgets('says so when a session carries no roles', (tester) async {
      // Distinct from hiding everything silently: an empty role set is
      // usually a claim path pointing at the wrong place.
      await pump(
        tester,
        const Scaffold(body: SessionIndicator()),
        const AuthState(status: AuthStatus.signedIn, displayName: 'Ada'),
      );

      await tester.tap(find.byType(PopupMenuButton<void>));
      await tester.pumpAndSettle();

      expect(find.text('No roles granted'), findsOneWidget);
    });
  });

  group('RoleGate', () {
    const Widget gated = RoleGate(
      role: Roles.admin,
      child: Text('delete everything'),
    );

    testWidgets('offers the action to somebody holding the role',
        (tester) async {
      await pump(
        tester,
        const Scaffold(body: gated),
        const AuthState(status: AuthStatus.signedIn, roles: {Roles.admin}),
      );

      expect(find.text('delete everything'), findsOneWidget);
    });

    testWidgets('withholds it from somebody without the role', (tester) async {
      await pump(
        tester,
        const Scaffold(body: gated),
        const AuthState(status: AuthStatus.signedIn, roles: {Roles.editor}),
      );

      expect(find.text('delete everything'), findsNothing);
    });

    testWidgets('withholds it from a session that has ended', (tester) async {
      await pump(
        tester,
        const Scaffold(body: gated),
        const AuthState(status: AuthStatus.expired, roles: {Roles.admin}),
      );

      expect(find.text('delete everything'), findsNothing);
    });

    testWidgets('offers everything where no provider is configured',
        (tester) async {
      // No provider means no roles to withhold; gating here would break a
      // deployment that never opted in.
      await pump(
        tester,
        const Scaffold(body: gated),
        const AuthState.disabled(),
      );

      expect(find.text('delete everything'), findsOneWidget);
    });

    testWidgets('shows a fallback where one is given', (tester) async {
      await pump(
        tester,
        const Scaffold(
          body: RoleGate(
            role: Roles.admin,
            fallback: Text('ask an administrator'),
            child: Text('delete everything'),
          ),
        ),
        const AuthState(status: AuthStatus.signedIn),
      );

      expect(find.text('ask an administrator'), findsOneWidget);
    });
  });
}
