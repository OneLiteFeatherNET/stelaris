import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/attributes/attribute_detail_page.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/edit_card.dart';
import '../../support/fake_http_client_adapter.dart';
import '../../support/settle_requests.dart';

void main() {
  group('AttributeDetailPage', () {
    const selected = AttributeModel(
      id: 'attr-1',
      uiName: 'Health',
      key: 'max_health',
      defaultValue: 10,
      minimumValue: 1,
      maximumValue: 20,
    );

    late Store<AppState> store;

    Future<void> pumpPage(
      WidgetTester tester, {
      AttributeModel attribute = selected,
    }) async {
      // Wide enough for the header's actions to keep their labels.
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      store = Store<AppState>(
        initialState: AppState(
          selectedProject: const Project(id: 'p', key: 'p', displayName: 'P'),
          selectedAttribute: attribute,
          attributes: PaginatedResult<AttributeModel>(
            items: [attribute],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      final router = GoRouter(
        initialLocation: '/projects/p/attributes/${attribute.id}',
        routes: [
          GoRoute(
            path: '/projects/:projectId/attributes',
            builder: (context, state) =>
                const Scaffold(body: Text('Attribute List')),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => const AttributeDetailPage(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    /// The card labelled [label].
    Finder cardOf(String label) => find.widgetWithText(EditCard, label);

    testWidgets('shows a back bar with the selected attribute name', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.byType(PageHeader), findsOneWidget);
      expect(find.text('Health'), findsOneWidget);
    });

    testWidgets('shows the values without a fraction when whole', (
      tester,
    ) async {
      await pumpPage(tester, attribute: selected.copyWith(defaultValue: 2.5));

      for (final (label, value) in [
        ('Minimum value', '1'),
        ('Default value', '2.5'),
        ('Maximum value', '20'),
      ]) {
        expect(
          find.descendant(of: cardOf(label), matching: find.text(value)),
          findsOneWidget,
        );
      }
    });

    testWidgets('a value in range is staged as unsaved', (tester) async {
      await pumpPage(tester);

      await editCard(tester, 'Minimum value', '-1');
      await editCard(tester, 'Default value', '-0.5');

      final attribute = store.state.selectedAttribute!;
      expect(attribute.defaultValue, -0.5);
      expect(attribute.minimumValue, -1);
      expect(store.state.unsavedChanges, NavigationEntry.attributes);
    });

    for (final (label, input, error) in [
      ('Minimum value', '11', 'The maximum is 10'),
      ('Default value', '0', 'The minimum is 1'),
      ('Default value', '21', 'The maximum is 20'),
      ('Maximum value', '5', 'The minimum is 10'),
      ('Maximum value', '0', 'Enter a number greater than 0'),
      ('Maximum value', '-', 'Please enter a valid number'),
    ]) {
      testWidgets('rejects "$input" as the ${label.toLowerCase()}', (
        tester,
      ) async {
        await pumpPage(tester);

        await editCard(tester, label, input);

        expect(find.text(error), findsOneWidget);
        expect(store.state.selectedAttribute, selected);
        expect(store.state.unsavedChanges, isNull);
      });
    }

    testWidgets('the synced segment toggles the flag', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.text('Synced'));
      await tester.pumpAndSettle();

      expect(store.state.selectedAttribute?.synced, isTrue);
      expect(store.state.unsavedChanges, NavigationEntry.attributes);
    });

    testWidgets('an emptied translation key is removed', (tester) async {
      await pumpPage(
        tester,
        attribute: selected.copyWith(translationKey: 'attribute.name.health'),
      );

      await editCard(tester, 'Translation key', '');

      expect(store.state.selectedAttribute?.translationKey, isNull);
    });

    testWidgets('saving sends the new fields to the backend', (tester) async {
      Map<String, dynamic>? sent;
      (ApiService().attributeApi as BaseApi<AttributeModel>)
          .apiClient
          .dio
          .httpClientAdapter = FakeHttpClientAdapter((options) {
        sent = options.data as Map<String, dynamic>;
        return ResponseBody.fromString(
          jsonEncode(sent),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
      await pumpPage(tester);

      await tester.tap(find.text('Synced'));
      await tester.pumpAndSettle();
      await editCard(tester, 'Translation key', 'attribute.name.health');
      await tester.tap(find.text('Save'));
      await settleRequests(tester, () => store.state.unsavedChanges != null);

      expect(sent?['synced'], isTrue);
      expect(sent?['minimumValue'], 1);
      expect(sent?['translationKey'], 'attribute.name.health');
      expect(store.state.unsavedChanges, isNull);
      expect(store.state.attributes.items.first.synced, isTrue);
    });

    testWidgets('leaving the page clears the selection', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('page_header_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Attribute List'), findsOneWidget);
      expect(store.state.selectedAttribute, isNull);
    });
  });

  group('AttributeDetailPage.locationOf', () {
    const selectedProject = Project(id: 'p', key: 'p', displayName: 'P');

    test('names the project the attribute belongs to', () {
      expect(
        AttributeDetailPage.locationOf(
          const AttributeModel(uiName: 'a', id: 'a', projectId: 'q'),
          const AppState(selectedProject: selectedProject),
        ),
        '/projects/q/attributes/a',
      );
    });

    test('falls back to the selected project', () {
      expect(
        AttributeDetailPage.locationOf(
          const AttributeModel(uiName: 'a', id: 'a'),
          const AppState(selectedProject: selectedProject),
        ),
        '/projects/p/attributes/a',
      );
    });
  });
}
