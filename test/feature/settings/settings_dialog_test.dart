import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/auth/auth_state.dart';
import 'package:stelaris/feature/base/dialog/form_dialog.dart';
import 'package:stelaris/feature/settings/settings_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('SettingsDialog Widget Tests', () {
    const project = Project(id: 'a', displayName: 'Project A', key: 'a');

    /// Opens the dialog from a button, as the app bar does.
    Future<void> openDialog(
      WidgetTester tester, {
      AuthState auth = const AuthState.disabled(),
    }) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final store = Store<AppState>(
        initialState: AppState(
          projects: const [project],
          selectedProject: project,
          auth: auth,
        ),
      );
      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const SettingsDialog(),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    double top(WidgetTester tester, String text) =>
        tester.getTopLeft(find.text(text)).dy;

    testWidgets('is a form dialog titled Settings', (tester) async {
      await openDialog(tester);

      expect(find.byType(FormDialog), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('is at most 560 wide', (tester) async {
      await openDialog(tester);

      expect(tester.widget<FormDialog>(find.byType(FormDialog)).maxWidth, 560);
      final panel = find
          .descendant(of: find.byType(Dialog), matching: find.byType(Material))
          .first;
      expect(tester.getSize(panel).width, lessThanOrEqualTo(560));
    });

    testWidgets('has a close icon and no Save or Cancel', (tester) async {
      await openDialog(tester);

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Save'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('lists the sections in order', (tester) async {
      await openDialog(tester);

      final headings = ['Project', 'Appearance', 'Accessibility', 'About'];
      final tops = [for (final heading in headings) top(tester, heading)];

      expect(tops, orderedEquals([...tops]..sort()));
    });

    testWidgets('puts the account section first when signed in', (
      tester,
    ) async {
      await openDialog(
        tester,
        auth: const AuthState(status: AuthStatus.signedIn),
      );

      expect(top(tester, 'Account'), lessThan(top(tester, 'Project')));
    });

    testWidgets('closes with the close icon', (tester) async {
      await openDialog(tester);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsDialog), findsNothing);
    });
  });
}
