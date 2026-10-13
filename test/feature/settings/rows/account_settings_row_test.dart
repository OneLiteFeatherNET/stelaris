import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_state.dart';
import 'package:stelaris/auth/roles.dart';
import 'package:stelaris/feature/settings/rows/account_settings_row.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('AccountSettingsRow Widget Tests', () {
    /// Pumps the row and returns how often sign-out ran, in a list the
    /// fake sign-out appends to.
    Future<List<void>> pumpRow(WidgetTester tester, AuthState auth) async {
      final signOuts = <void>[];
      final store = Store<AppState>(initialState: AppState(auth: auth));

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AccountSettingsRow(
                  signOut: () async => signOuts.add(null),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return signOuts;
    }

    const signedIn = AuthState(
      status: AuthStatus.signedIn,
      displayName: 'Ada',
      roles: {Roles.editor, Roles.admin},
    );

    testWidgets('shows the heading, the name and the roles when signed in', (
      tester,
    ) async {
      await pumpRow(tester, signedIn);

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Ada'), findsOneWidget);
      expect(find.textContaining(Roles.editor), findsOneWidget);
      expect(find.textContaining(Roles.admin), findsOneWidget);
    });

    testWidgets('says signed in when the provider released no name', (
      tester,
    ) async {
      await pumpRow(tester, const AuthState(status: AuthStatus.signedIn));

      expect(find.text('Signed in'), findsOneWidget);
      expect(find.text('No roles granted'), findsOneWidget);
    });

    testWidgets('runs sign-out once when Sign out is tapped', (tester) async {
      final signOuts = await pumpRow(tester, signedIn);

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(signOuts, hasLength(1));
    });

    testWidgets('explains that no one is signed in', (tester) async {
      await pumpRow(tester, const AuthState(status: AuthStatus.signedOut));

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('No one is signed in.'), findsOneWidget);
    });

    testWidgets('says the session expired instead of that no one is in', (
      tester,
    ) async {
      await pumpRow(tester, const AuthState(status: AuthStatus.expired));

      expect(
        find.text('Your session expired. Sign in again to continue.'),
        findsOneWidget,
      );
      expect(find.text('No one is signed in.'), findsNothing);
      expect(find.text('Sign out'), findsNothing);
    });

    testWidgets('shortens a long role list like the account menu', (
      tester,
    ) async {
      await pumpRow(
        tester,
        AuthState(
          status: AuthStatus.signedIn,
          displayName: 'Ada',
          roles: {for (var i = 0; i < 30; i++) 'group-id-$i'},
        ),
      );

      expect(find.textContaining('and 27 more'), findsOneWidget);
      expect(find.textContaining('group-id-29'), findsNothing);
    });

    testWidgets('offers no sign-out when no one is signed in', (tester) async {
      await pumpRow(tester, const AuthState(status: AuthStatus.signedOut));

      expect(find.text('Sign out'), findsNothing);
    });

    testWidgets('shows nothing, not even the heading, without a provider', (
      tester,
    ) async {
      await pumpRow(tester, const AuthState.disabled());

      expect(find.text('Account'), findsNothing);
      expect(find.byType(Card), findsNothing);
    });
  });
}
