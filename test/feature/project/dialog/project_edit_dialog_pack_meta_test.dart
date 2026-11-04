import 'package:async_redux/async_redux.dart';

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/component/minimessage_field.dart';
import 'package:stelaris/feature/project/dialog/project_edit_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/minimessage_json.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/fake_pack_meta_api.dart';
import '../../../support/pump_until.dart';

void main() {
  const project = Project(id: 'p1', displayName: 'Project', key: 'proj');
  const existing = PackMeta(
    id: 'meta-1',
    projectId: 'p1',
    packType: PackType.resource,
    description: '"My pack"',
    minFormatMajor: 46,
    maxFormatMajor: 48,
    maxFormatMinor: 1,
    enabledFeatures: ['minecraft:trade_rebalance'],
  );

  setUp(() {
    // The project save echoes the sent project.
    ApiService().projectApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter(
          (options) => FakeHttpClientAdapter.response(options.data),
        );
  });

  Future<void> pumpDialog(
    WidgetTester tester,
    FakePackMetaApi api, {
    void Function(Object? result)? onResult,
  }) async {
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: Store<AppState>(
          initialState: const AppState(
            projects: [project],
            selectedProject: project,
          ),
        ),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  final result = await showDialog<Object>(
                    context: context,
                    builder: (_) =>
                        EditProjectDialog(project: project, packMetaApi: api),
                  );
                  onResult?.call(result);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> openMetaTab(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(Tab, 'Pack'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester, bool Function() done) => pumpUntil(
    tester,
    action: () => tester.tap(find.text('Save')),
    done: done,
  );

  Finder field(String label) => find.widgetWithText(TextFormField, label);
  final description = find.descendant(
    of: find.byType(MiniMessageField),
    matching: find.byType(EditableText),
  );

  testWidgets('shows the stored pack meta in its tab', (tester) async {
    await pumpDialog(tester, FakePackMetaApi(stored: existing));

    expect(description, findsNothing);
    await openMetaTab(tester);

    expect(tester.widget<EditableText>(description).controller.text, 'My pack');
    expect(find.text('46'), findsOneWidget);
    expect(find.text('48'), findsOneWidget);
  });

  testWidgets('an unchanged pack meta is not sent again', (tester) async {
    final api = FakePackMetaApi(stored: existing);
    Object? result;
    await pumpDialog(tester, api, onResult: (value) => result = value);

    await save(tester, () => result != null);

    expect(api.puts, isEmpty);
    expect(api.deletes, isEmpty);
  });

  testWidgets('filling in the pack meta creates it on save', (tester) async {
    final api = FakePackMetaApi();
    Object? result;
    await pumpDialog(tester, api, onResult: (value) => result = value);
    await openMetaTab(tester);

    await tester.enterText(description, '<red>Pack');
    await tester.enterText(field('Min format *'), '46');
    await tester.enterText(field('Max format *'), '48');
    await save(tester, () => result != null);

    expect(result, isA<Project>());
    expect(api.puts, [
      PackMeta(
        packType: PackType.resource,
        description: jsonEncode(MiniMessageJson.encode('<red>Pack')),
        minFormatMajor: 46,
        maxFormatMajor: 48,
      ),
    ]);
  });

  testWidgets('an edited description is stored as a text component', (
    tester,
  ) async {
    final api = FakePackMetaApi(stored: existing);
    Object? result;
    await pumpDialog(tester, api, onResult: (value) => result = value);
    await openMetaTab(tester);

    await tester.enterText(description, '<bold>Other');
    await save(tester, () => result != null);

    // The enabled features are no longer edited here, but kept.
    expect(api.puts, [
      existing.copyWith(
        description: jsonEncode(MiniMessageJson.encode('<bold>Other')),
      ),
    ]);
  });

  testWidgets('clearing a stored pack meta removes it on save', (tester) async {
    final api = FakePackMetaApi(stored: existing);
    Object? result;
    await pumpDialog(tester, api, onResult: (value) => result = value);
    await openMetaTab(tester);

    await tester.enterText(description, '');
    for (final text in ['46', '0', '48', '1']) {
      await tester.enterText(field(text), '');
    }
    await tester.pumpAndSettle();
    await save(tester, () => result != null);

    expect(api.deletes, [PackType.resource]);
    expect(api.puts, isEmpty);
  });

  testWidgets('an invalid pack meta blocks the save and shows its tab', (
    tester,
  ) async {
    final api = FakePackMetaApi(stored: existing);
    await pumpDialog(tester, api);
    await openMetaTab(tester);

    await tester.enterText(description, '');
    await tester.enterText(field('48'), '40');
    await tester.tap(find.widgetWithText(Tab, 'Project'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProjectDialog), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
    expect(find.text('Below the min format'), findsOneWidget);
    expect(api.puts, isEmpty);
  });

  testWidgets('a partly filled pack meta asks for the required fields', (
    tester,
  ) async {
    final api = FakePackMetaApi();
    await pumpDialog(tester, api);
    await openMetaTab(tester);

    await tester.enterText(field('Min format *'), '46');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(EditProjectDialog), findsOneWidget);
    expect(find.text('Description is required'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(api.puts, isEmpty);
  });

  testWidgets('a failed load offers a retry and leaves the meta alone', (
    tester,
  ) async {
    final api = FakePackMetaApi(stored: existing, failLoad: true);
    Object? result;
    await pumpDialog(tester, api, onResult: (value) => result = value);
    await openMetaTab(tester);

    expect(find.text('The pack.mcmeta could not be loaded'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await save(tester, () => result != null);
    expect(api.puts, isEmpty);
    expect(api.deletes, isEmpty);
  });
}
