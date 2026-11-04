import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/asset/preview/texture_preview.dart';
import 'package:stelaris/feature/font/font_detail_page.dart';
import 'package:stelaris/feature/base/edit_card/edit_card.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/util/navigation.dart';

import '../../support/edit_card.dart';
import '../../support/fake_http_client_adapter.dart';

void main() {
  group('FontDetailPage', () {
    const selected = FontModel(
      id: 'font-1',
      uiName: 'Roboto Mono',
      height: 8,
    );

    late Store<AppState> store;


    const project = Project(id: 'p-1', displayName: 'Cygnus', key: 'cygnus');

    Future<void> pumpPage(
      WidgetTester tester, {
      String location = '/fonts/detail',
      FontModel font = selected,
      Project? project,
    }) async {
      store = Store<AppState>(
        initialState: AppState(selectedFont: font, selectedProject: project),
      );

      final router = GoRouter(
        initialLocation: location,
        routes: [
          GoRoute(
            path: '/fonts',
            builder: (context, state) => const Scaffold(body: Text('Font List')),
            routes: [
              GoRoute(
                path: 'detail',
                // In the app the shell's Scaffold sits above; the Chars tab
                // needs its Material once a test opens on it.
                builder: (context, state) =>
                    const Scaffold(body: FontDetailPage()),
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

    testWidgets(
      'shows the back arrow with the font name above the tabs',
      (tester) async {
        await pumpPage(tester);

        expect(find.byType(PageHeader), findsOneWidget);
        expect(find.text('Roboto Mono'), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);

        final backBarPosition = tester.getTopLeft(
          find.byType(PageHeader),
        );
        final tabBarPosition = tester.getTopLeft(find.byType(TabBar));
        expect(backBarPosition.dy, lessThan(tabBarPosition.dy));

        expect(find.text('General'), findsOneWidget);
        expect(find.text('Characters'), findsOneWidget);
      },
    );

  
    int selectedTab(WidgetTester tester) =>
        DefaultTabController.of(tester.element(find.byType(TabBar))).index;

    testWidgets('?tab=characters opens on the Characters tab', (tester) async {
      // The Chars tab loads its entries as soon as it is shown.
      ApiService().fontApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(
            const PaginatedResult<FontStringDTO>(
              items: [],
              totalItems: 0,
              totalPages: 0,
              currentPage: 1,
              pageSize: 10,
            ).toJson((c) => c.toJson()),
          );
      await pumpPage(tester, location: '/fonts/detail?tab=characters');

      expect(selectedTab(tester), 1);
    });

    testWidgets('an old ?tab=fontface link opens on General', (tester) async {
      await pumpPage(tester, location: '/fonts/detail?tab=fontface');

      expect(selectedTab(tester), 0);
    });

    Map<String, Object?> textureJson(String id, String key) => {
      'id': id,
      'projectId': 'p-1',
      'key': key,
      'displayName': key,
      'kind': 'TEXTURE',
      'fileName': 'ghost.png',
      'contentType': 'image/png',
      'size': 1,
      'sha1': 'aaaa',
      'derivedAssetIds': <String>[],
    };

    testWidgets('without a project the texture card is hidden', (
      tester,
    ) async {
      await pumpPage(tester);

      expect(find.text('Texture'), findsNothing);
    });

    testWidgets('the texture card shows the key of the texture asset', (
      tester,
    ) async {
      final requests = <String>[];
      ApiService().assetApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            requests.add(options.uri.path);
            return FakeHttpClientAdapter.response(
              textureJson('t-1', 'cygnus:font/ghost'),
            );
          });
      await pumpPage(
        tester,
        font: selected.copyWith(textureAssetId: 't-1'),
        project: project,
      );

      expect(find.text('cygnus:font/ghost'), findsOneWidget);
      expect(requests.single, endsWith('/project/p-1/asset/t-1'));
    });

    testWidgets('a texture that can not be loaded is named missing', (
      tester,
    ) async {
      ApiService().assetApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json({
            'title': 'Not found',
            'status': 404,
          }, statusCode: 404);
      await pumpPage(
        tester,
        font: selected.copyWith(textureAssetId: 't-1'),
        project: project,
      );

      expect(find.text('The texture could not be loaded'), findsOneWidget);
    });

    testWidgets('choosing a texture stages its id and shows its key', (
      tester,
    ) async {
      ApiService().assetApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
            final kind = options.uri.queryParameters['kind'];
            return FakeHttpClientAdapter.response({
              'items': [
                if (kind == 'TEXTURE') textureJson('t-2', 'cygnus:font/clock'),
              ],
              'totalItems': kind == 'TEXTURE' ? 1 : 0,
              'totalPages': 1,
              'currentPage': 0,
              'pageSize': 50,
            });
          });
      await pumpPage(tester, project: project);

      await tester.tap(find.text('Texture'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a texture'), findsOneWidget);
      await tester.tap(find.text('cygnus:font/clock'));
      await tester.pumpAndSettle();
      expect(find.byType(TexturePreview), findsOneWidget);
      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();

      expect(store.state.selectedFont?.textureAssetId, 't-2');
      expect(store.state.unsavedChanges, NavigationEntry.font);
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('cygnus:font/clock'), findsOneWidget);
    });

    testWidgets('a number field takes only digits', (tester) async {
      await pumpPage(tester);

      await editCard(tester, 'Ascent', '7x');

      expect(store.state.selectedFont?.ascent, 7);
    });

    testWidgets('the ascent takes a negative number', (tester) async {
      await pumpPage(tester);

      await editCard(tester, 'Ascent', '-3');

      expect(store.state.selectedFont?.ascent, -3);
    });

    testWidgets('a lone minus keeps the ascent dialog open', (tester) async {
      await pumpPage(tester);
      final before = store.state.selectedFont?.ascent;

      await editCard(tester, 'Ascent', '-');

      expect(find.text('Please enter a valid number'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      expect(store.state.selectedFont?.ascent, before);
    });

    testWidgets('an ascent above the height keeps the dialog open', (
      tester,
    ) async {
      await pumpPage(tester);

      await editCard(tester, 'Ascent', '9');

      expect(find.text('The maximum is 8'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      expect(store.state.selectedFont?.ascent, 0);
    });

    testWidgets('a height below the ascent keeps the dialog open', (
      tester,
    ) async {
      await pumpPage(tester);
      await editCard(tester, 'Ascent', '7');

      await editCard(tester, 'Height', '6');

      expect(find.text('The minimum is 7'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      expect(store.state.selectedFont?.height, 8);
    });

    testWidgets('cancel changes nothing', (tester) async {
      await pumpPage(tester);
      final before = store.state.selectedFont;

      await tester.tap(find.widgetWithText(EditCard, 'Height'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.byType(TextFormField),
        ),
        '99',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(store.state.selectedFont, before);
      expect(store.state.unsavedChanges, isNull);
    });
});
}
