import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/routes.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../support/fake_http_client_adapter.dart';

void main() {
  setUp(() {
    ApiService().projectApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json(
      const PaginatedResult<Project>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 50,
      ).toJson((p) => p.toJson()),
    );
  });

  testWidgets('GoRouter redirect sends user to /projects when selectedProject is null', (
    tester,
  ) async {
    final store = Store<AppState>(initialState: const AppState());

    router.go(NavigationEntry.attributes.route);

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

    expect(
      router.routerDelegate.currentConfiguration.uri.toString(),
      projectSelectionRoute,
    );
  });
}
