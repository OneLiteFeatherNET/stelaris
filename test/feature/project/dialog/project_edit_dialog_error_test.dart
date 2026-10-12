import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/dialog/project_edit_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pump_until.dart';

void main() {
  testWidgets('a failed save keeps the dialog open and shows why', (
    tester,
  ) async {
    const project = Project(id: 'p1', displayName: 'Old', key: 'old');
    ApiService().projectApi.apiClient.dio.httpClientAdapter =
        FakeHttpClientAdapter.json({
          'title': 'Broken',
          'status': 500,
        }, statusCode: 500);
    Object? dialogResult = 'open';
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
                onPressed: () async => dialogResult = await showDialog<Object>(
                  context: context,
                  builder: (_) => const EditProjectDialog(project: project),
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

    await tester.enterText(find.byType(TextFormField).first, 'New');
    await pumpUntil(
      tester,
      action: () => tester.tap(find.byType(FilledButton)),
      done: () => find.byType(SnackBar).evaluate().isNotEmpty,
    );

    expect(find.byType(EditProjectDialog), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(dialogResult, 'open');
  });
}
