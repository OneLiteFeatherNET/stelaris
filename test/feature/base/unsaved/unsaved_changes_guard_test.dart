import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/unsaved/detail_forms.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_changes_guard.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  late Store<AppState> store;
  bool? result;

  Future<void> pump(WidgetTester tester, AppState state) async {
    store = Store<AppState>(initialState: state);
    result = null;
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    result = await confirmLeaveIfDirty(context),
                child: const Text('leave'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('allows leaving without a dialog when nothing is unsaved', (
    tester,
  ) async {
    await pump(tester, const AppState());

    await tester.tap(find.text('leave'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(result, isTrue);
  });

  testWidgets('cancel keeps the user on the page', (tester) async {
    await pump(tester, const AppState(unsavedChanges: NavigationEntry.items));

    await tester.tap(find.text('leave'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.byKey(const Key('unsaved_dialog_cancel')));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(store.state.unsavedChanges, NavigationEntry.items);
  });

  testWidgets('discard clears the flag and allows leaving', (tester) async {
    await pump(tester, const AppState(unsavedChanges: NavigationEntry.items));

    await tester.tap(find.text('leave'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('unsaved_dialog_discard')));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(store.state.unsavedChanges, isNull);
  });

  testWidgets('save with an invalid registered form stays on the page', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    store = Store<AppState>(
      initialState: const AppState(unsavedChanges: NavigationEntry.items),
    );
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  Form(
                    key: formKey,
                    child: TextFormField(validator: (_) => 'invalid'),
                  ),
                  RegisterDetailForm(formKey: formKey),
                  TextButton(
                    onPressed: () async =>
                        result = await confirmLeaveIfDirty(context),
                    child: const Text('leave'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('leave'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('unsaved_dialog_save')));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.text('invalid'), findsOneWidget);
  });

  testWidgets('RegisterDetailForm unregisters on dispose', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Form(
                key: formKey,
                child: TextFormField(validator: (_) => 'invalid'),
              ),
              RegisterDetailForm(formKey: formKey),
            ],
          ),
        ),
      ),
    );
    expect(DetailForms.validateAll(), isFalse);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(DetailForms.validateAll(), isTrue);
  });
}
