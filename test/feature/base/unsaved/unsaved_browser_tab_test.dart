import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/actions/unsaved_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/base/unsaved/unsaved_browser_tab.dart';
import 'package:stelaris/util/constants.dart';

void main() {
  late Store<AppState> store;
  late List<bool> warnings;

  Future<void> pump(WidgetTester tester, AppState state) async {
    store = Store<AppState>(initialState: state);
    warnings = [];
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          title: appName,
          builder: (context, child) =>
              UnsavedBrowserTab(leaveWarning: warnings.add, child: child!),
          home: const SizedBox(),
        ),
      ),
    );
  }

  Finder titled(String title) =>
      find.byWidgetPredicate((w) => w is Title && w.title == title);

  testWidgets('shows the plain title and no warning when all is saved', (
    tester,
  ) async {
    await pump(tester, const AppState());

    expect(titled(unsavedAppTitle), findsNothing);
    expect(warnings, [false]);
  });

  testWidgets('a page opened with unsaved edits shows them at once', (
    tester,
  ) async {
    await pump(tester, const AppState(unsavedChanges: NavigationEntry.items));

    expect(titled(unsavedAppTitle), findsOneWidget);
    expect(warnings, [true]);
  });

  testWidgets('follows unsaved edits as they come and go', (tester) async {
    await pump(tester, const AppState());

    store.dispatch(MarkUnsavedChangesAction(NavigationEntry.sound));
    await tester.pumpAndSettle();
    expect(titled(unsavedAppTitle), findsOneWidget);

    store.dispatch(DiscardUnsavedChangesAction());
    await tester.pumpAndSettle();
    expect(titled(unsavedAppTitle), findsNothing);

    expect(warnings, [false, true, false]);
  });

  testWidgets('turns the warning off when it goes away', (tester) async {
    await pump(tester, const AppState(unsavedChanges: NavigationEntry.font));

    await tester.pumpWidget(const SizedBox());

    expect(warnings, [true, false]);
  });
}
