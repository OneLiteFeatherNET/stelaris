import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/item/lore/lore_page.dart';
import 'package:stelaris/feature/item/lore/lore_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('LorePage preview', () {
    setUp(() {
      ApiService().itemApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json({
            'items': [
              {'id': '1', 'text': 'First line'},
              {'id': '2', 'text': 'Second line'},
            ],
            'totalItems': 2,
            'totalPages': 1,
            // The only page, so the list doesn't load another one.
            'currentPage': 1,
            'pageSize': 10,
          });
    });

    Future<void> pumpLorePage(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final store = Store<AppState>(
        initialState: const AppState().copyWith(
          selectedItem: const ItemModel(id: 'item-1', uiName: 'item'),
        ),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: LorePage()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final toggle = find.byKey(const Key('lore_preview_toggle'));

    testWidgets('the toggle hides and shows the preview on wide layouts', (
      tester,
    ) async {
      await pumpLorePage(tester, const Size(1400, 900));
      expect(find.byType(LorePreview), findsOneWidget);

      await tester.tap(toggle);
      // Still on its way out, then gone.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LorePreview), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(LorePreview), findsNothing);

      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byType(LorePreview), findsOneWidget);
    });

    testWidgets('the preview takes a share of the width within bounds', (
      tester,
    ) async {
      await pumpLorePage(tester, const Size(1400, 900));
      // 1400 minus the page padding, 35 % of that is 476, capped at 420.
      expect(tester.getSize(find.byType(LorePreview)).width, 420);
    });

    testWidgets('the preview starts at the top, level with the list', (
      tester,
    ) async {
      await pumpLorePage(tester, const Size(1400, 900));
      expect(
        tester.getTopLeft(find.byType(LorePreview)).dy,
        tester.getTopLeft(find.byType(ReorderableListView)).dy,
      );
    });

    testWidgets('the toggle opens the preview as a sheet on narrow layouts', (
      tester,
    ) async {
      await pumpLorePage(tester, const Size(700, 900));
      expect(find.byType(LorePreview), findsNothing);

      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BottomSheet),
          matching: find.text('Second line'),
        ),
        findsOneWidget,
      );
    });
  });
}
