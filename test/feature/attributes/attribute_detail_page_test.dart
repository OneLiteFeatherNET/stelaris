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

import '../../support/fake_http_client_adapter.dart';

void main() {
  group('AttributeDetailPage', () {
    const selected = AttributeModel(
      id: 'attr-1',
      uiName: 'Health',
      key: 'max_health',
      defaultValue: 10,
      maximumValue: 20,
    );

    late Store<AppState> store;

    Future<void> pumpPage(
      WidgetTester tester, {
      AttributeModel attribute = selected,
    }) async {
      store = Store<AppState>(
        initialState: AppState(
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
        initialLocation: '/attributes/detail',
        routes: [
          GoRoute(
            path: '/attributes',
            builder: (context, state) =>
                const Scaffold(body: Text('Attribute List')),
            routes: [
              GoRoute(
                path: 'detail',
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

    /// Opens the card labelled [label], types [text] and saves with Enter.
    Future<void> enterAndBlur(
      WidgetTester tester,
      String label,
      String text,
    ) async {
      await tester.ensureVisible(cardOf(label));
      await tester.tap(cardOf(label));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(TextFormField),
        ),
        text,
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

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

      await enterAndBlur(tester, 'Default value', '-0.5');
      await enterAndBlur(tester, 'Maximum value', '0.75');

      final attribute = store.state.selectedAttribute!;
      expect(attribute.defaultValue, -0.5);
      expect(attribute.maximumValue, 0.75);
      expect(store.state.unsavedChanges, NavigationEntry.attributes);
    });

    for (final (label, input, error) in [
      ('Default value', '-', 'Please enter a valid number'),
      ('Maximum value', '0', 'Enter a number greater than 0'),
      ('Maximum value', '-', 'Please enter a valid number'),
    ]) {
      testWidgets('rejects "$input" as the ${label.toLowerCase()}', (
        tester,
      ) async {
        await pumpPage(tester);

        await enterAndBlur(tester, label, input);

        expect(find.text(error), findsOneWidget);
        expect(store.state.selectedAttribute, selected);
        expect(store.state.unsavedChanges, isNull);
      });
    }

    testWidgets('saving sends the values to the backend', (tester) async {
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

      await enterAndBlur(tester, 'Default value', '15');
      await tester.tap(find.text('Save'));
      // On the web, dio finishes even a faked request in several real-async
      // steps that testWidgets' fake-async zone doesn't run on its own, so
      // alternate frames with a little real time until the save has landed.
      for (var i = 0; i < 20 && store.state.unsavedChanges != null; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
      }
      await tester.pumpAndSettle();

      expect(sent?['defaultValue'], 15);
      expect(sent?['maximumValue'], 20);
      expect(store.state.unsavedChanges, isNull);
      expect(store.state.attributes.items.first.defaultValue, 15);
    });

    testWidgets('leaving the page clears the selection', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byKey(const Key('page_header_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Attribute List'), findsOneWidget);
      expect(store.state.selectedAttribute, isNull);
    });
  });
}
