import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/app.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import 'support/fake_http_client_adapter.dart';

void main() {
  group('StelarisApp Widget Tests', () {
    setUp(() {
      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter.json(
        const PaginatedResult<Project>(
          items: [],
          totalItems: 0,
          totalPages: 0,
          currentPage: 1,
          pageSize: 10,
        ).toJson((p) => p.toJson()),
      );
    });

    testWidgets('provides supportedLocales and Material 3 theme to MaterialApp', (tester) async {
      final store = Store<AppState>(
        initialState: const AppState(),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: const StelarisApp(),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.supportedLocales, equals(AppLocalizations.supportedLocales));
      expect(materialApp.theme?.useMaterial3, isTrue);
      expect(materialApp.darkTheme?.useMaterial3, isTrue);
    });

    testWidgets('scales text theme based on fontScale setting', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const defaultState = AppState();
      final defaultStore = Store<AppState>(initialState: defaultState);

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: defaultStore,
          child: const StelarisApp(),
        ),
      );
      await tester.pumpAndSettle();

      final defaultApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final defaultTitleSize = defaultApp.theme?.textTheme.titleLarge?.fontSize;
      expect(defaultTitleSize, isNotNull);

      // Now with 1.5 font scale
      final scaledStore = Store<AppState>(
        initialState: AppState(
          themeSettings: ThemeSettings.defaultSettings().copyWith(fontScale: 1.5),
        ),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: scaledStore,
          child: const StelarisApp(),
        ),
      );
      await tester.pumpAndSettle();

      final scaledApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final scaledTitleSize = scaledApp.theme?.textTheme.titleLarge?.fontSize;
      expect(scaledTitleSize, closeTo(defaultTitleSize! * 1.5, 0.001));
    });

    testWidgets('allows routerConfig injection for isolated testing', (tester) async {
      final store = Store<AppState>(initialState: const AppState());
      final customRouter = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Text('Injected Router Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: StelarisApp(routerConfig: customRouter),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Injected Router Page'), findsOneWidget);
    });
  });
}
