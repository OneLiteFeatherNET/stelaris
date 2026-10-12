import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/dialog/project_create_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pump_until.dart';

void main() {
  testWidgets('a failed create keeps the dialog open and shows why', (
    tester,
  ) async {
    ApiService().projectApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json({
          'title': 'Broken',
          'status': 500,
        }, statusCode: 500);
    Object? dialogResult = 'open';
    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: Store<AppState>(initialState: const AppState()),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async => dialogResult = await showDialog<Object>(
                  context: context,
                  builder: (_) => const CreateProjectDialog(),
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

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'My Project');
    await tester.enterText(fields.at(1), 'my_project');
    await pumpUntil(
      tester,
      action: () => tester.tap(find.byType(FilledButton)),
      done: () => find.byType(SnackBar).evaluate().isNotEmpty,
    );

    expect(find.byType(CreateProjectDialog), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(dialogResult, 'open');
  });
}
