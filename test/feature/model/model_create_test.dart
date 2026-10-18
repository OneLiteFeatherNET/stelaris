import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/attribute_actions.dart';
import 'package:stelaris/api/state/actions/font/font_actions.dart';
import 'package:stelaris/api/state/actions/item_actions.dart';
import 'package:stelaris/api/state/actions/advancement_actions.dart';
import 'package:stelaris/api/state/actions/sound/sound_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/model/model_create.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/pump_until.dart';

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
  // Submitting dispatches an AddAction, which talks to the API; the dialog
  // waits for it and closes once the model exists, so it is stubbed to
  // answer like the backend. All of ApiService's model APIs share
  // one Dio client, so one stub covers every kind under test - echoing the
  // submitted body back is valid JSON for whichever model is being added.
  ApiService().itemApi.apiClient.dio.httpClientAdapter = FakeHttpClientAdapter(
    (options) => ResponseBody.fromString(
      jsonEncode(options.data),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    ),
  );
  final recorder = _Recorder();
  final results = <bool>[];
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: Store<AppState>(
        initialState: const AppState(),
        actionObservers: [recorder],
        // The add actions talk to the API, which a test has none of.
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
  // Tapping "Create" fires an AddAction, which talks to the (fake) API
  // through Dio's real Timer-guarded internals. Those don't resolve inside
  // flutter_test's fake-async zone on web, so this runs outside it, in a
  // real async zone, the same way the app would.
  await pumpUntil(
    tester,
    action: () => tester.tap(find.text('Create')),
    done: () =>
        find.byType(ModelCreateDialog).evaluate().isEmpty ||
        find.byType(SnackBar).evaluate().isNotEmpty,
  );
}

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

  final cases = <NavigationEntry, (String, Type)>{
    NavigationEntry.items: (l10n.dialog_item_create, ItemAddAction),
    NavigationEntry.font: (l10n.dialog_font_create_title, FontAddAction),
    NavigationEntry.sound: (l10n.dialog_sound_create, SoundAddAction),
    NavigationEntry.advancements: (
      l10n.dialog_advancement_create,
      AdvancementAddAction,
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

  testWidgets('a new font is sent as a bitmap with the default height', (
    tester,
  ) async {
    await _pump(tester, NavigationEntry.font);
    Object? sent;
    ApiService().fontApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter((options) {
          sent = options.data;
          return ResponseBody.fromString(
            jsonEncode(options.data),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

    await _submit(tester);

    final body = sent! as Map<String, dynamic>;
    expect(body['provider'], 'bitmap');
    expect(body['height'], 8);
  });

  testWidgets('a failed add keeps the dialog open and shows why', (
    tester,
  ) async {
    final (_, results) = await _pump(tester, NavigationEntry.items);
    ApiService().itemApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json(
          {'title': 'Broken', 'status': 500},
          statusCode: 500,
        );

    await _submit(tester);

    expect(results, isEmpty);
    expect(find.text('Ruby Sword'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('cancelling adds nothing and resolves to false', (tester) async {
    final (recorder, results) = await _pump(tester, NavigationEntry.items);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(recorder.dispatched, isEmpty);
    expect(results, [false]);
  });
}
