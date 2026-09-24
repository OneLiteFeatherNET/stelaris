import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/notification_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_create.dart';
import 'package:stelaris/l10n/app_localizations.dart';

import '../../support/fake_http_client_adapter.dart';

/// Records which actions were dispatched.
class _Recorder implements ActionObserver<AppState> {
  final List<Type> dispatched = [];

  @override
  void observe(
    ReduxAction<AppState> action,
    int dispatchCount, {
    required bool ini,
  }) {
    if (ini) {
      dispatched.add(action.runtimeType);
    }
  }
}

/// Pumps a button that opens the create dialog for [entry]; returns the
/// recorder and a holder for the dialog's result.
Future<(_Recorder, List<bool>)> _pump(
  WidgetTester tester,
  NavigationEntry entry,
) async {
  final recorder = _Recorder();
  final results = <bool>[];
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: Store<AppState>(
        initialState: const AppState(),
        actionObservers: [recorder],
        // The fake API answers every add with an error.
        globalErrorObserver: (_) => SwallowGlobalErrorObserver<AppState>(),
      ),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async => results.add(
                await openModelCreateDialog(context, entry, 'my_project'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
  return (recorder, results);
}

Future<void> _submit(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'Ruby Sword');
  await tester.enterText(find.byType(TextFormField).at(1), 'ruby_sword');
  await tester.tap(find.text('Create'));
  await tester.pumpAndSettle();
}

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  // The five lists share one client. Answer at once: a real request outlives
  // the test on the web and leaves Dio's timeout timer pending.
  setUp(() {
    ApiService().itemApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json(null, statusCode: 500);
  });

  final cases = <NavigationEntry, (String, Type)>{
    NavigationEntry.items: (l10n.dialog_item_create, ItemAddAction),
    NavigationEntry.font: (l10n.dialog_font_create_title, FontAddAction),
    NavigationEntry.sound: (l10n.dialog_sound_create, SoundAddAction),
    NavigationEntry.notifications: (
      l10n.dialog_notification_create,
      NotificationAddAction,
    ),
    NavigationEntry.attributes: (
      l10n.dialog_attribute_create,
      AttributeAddAction,
    ),
  };

  for (final MapEntry(key: entry, value: (title, action)) in cases.entries) {
    testWidgets('${entry.name}: shows its title and dispatches $action', (
      tester,
    ) async {
      final (recorder, results) = await _pump(tester, entry);
      expect(find.text(title), findsOneWidget);

      await _submit(tester);

      expect(recorder.dispatched, contains(action));
      expect(results, [true]);
    });
  }

  testWidgets('cancelling adds nothing and resolves to false', (tester) async {
    final (recorder, results) = await _pump(tester, NavigationEntry.items);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(recorder.dispatched, isEmpty);
    expect(results, [false]);
  });
}
