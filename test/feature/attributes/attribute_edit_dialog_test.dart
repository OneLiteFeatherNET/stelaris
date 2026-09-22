import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/attributes/attribute_edit_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';

void main() {
  group('AttributeEditDialog', () {
    const original = AttributeModel(
      id: 'attr-1',
      uiName: 'Health',
      defaultValue: 10,
      maximumValue: 20,
    );

    Future<Store<AppState>> pumpDialog(WidgetTester tester) async {
      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          attributes: const PaginatedResult<AttributeModel>(
            items: [original],
            totalItems: 1,
            totalPages: 1,
            currentPage: 1,
            pageSize: 10,
          ),
        ),
      );

      (ApiService().attributeApi as BaseApi<AttributeModel>)
          .apiClient
          .dio
          .httpClientAdapter =
          FakeHttpClientAdapter((options) {
        final body = options.data as Map<String, dynamic>;
        return ResponseBody.fromString(
          jsonEncode(body),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const AttributeEditDialog(
                      model: original,
                      projectKey: 'test',
                    ),
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

      return store;
    }

    testWidgets('pre-populates default and maximum value fields', (tester) async {
      await pumpDialog(tester);

      expect(find.text('Edit attribute'), findsOneWidget);
      expect(find.text('10.0'), findsOneWidget);
      expect(find.text('20.0'), findsOneWidget);
    }, skip: true);

    testWidgets('shows the attribute name as a subtitle under the title', (tester) async {
      await pumpDialog(tester);

      expect(find.text(original.uiName), findsOneWidget);
    });

    testWidgets('closes without dispatching when Cancel is pressed', (tester) async {
      final store = await pumpDialog(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edit attribute'), findsNothing);
      expect(store.state.attributes.items.first.defaultValue, 10);
    });

    testWidgets('saves edited values and persists them to the store', (tester) async {
      final store = await pumpDialog(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '15');
      await tester.enterText(fields.at(1), '30');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit attribute'), findsNothing);
      expect(store.state.attributes.items.first.defaultValue, 15);
      expect(store.state.attributes.items.first.maximumValue, 30);
      expect(store.state.selectedAttribute?.defaultValue, 15);
    }, skip: true);
  });
}
