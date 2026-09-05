import 'dart:convert';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/project/dialog/project_edit_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';

void main() {
  group('EditProjectDialog Widget Tests', () {
    const originalProject = Project(
      id: 'proj-123',
      displayName: 'Original Project',
      key: 'orig_key',
      description: 'Original Description',
      projectUrl: 'https://github.com/test/repo',
      docuUrl: 'https://docs.test.com',
      labor: false,
    );

    setUp(() {
      ApiService().projectApi.apiClient.dio.httpClientAdapter =
          FakeHttpClientAdapter((options) {
        final body = options.data;
        if (body is Map) {
          return ResponseBody.fromString(
            jsonEncode(body),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (body is String) {
          return ResponseBody.fromString(
            body,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode(
            originalProject.copyWith(displayName: 'Updated Name').toJson(),
          ),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    });

    Future<Store<AppState>> pumpDialog(
      WidgetTester tester, {
      Project project = originalProject,
      void Function(dynamic result)? onResult,
    }) async {
      final store = Store<AppState>(
        initialState: AppState(
          projects: [project],
          selectedProject: project,
        ),
      );

      await tester.pumpWidget(
        StoreProvider<AppState>(
          store: store,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    final res = await showDialog(
                      context: context,
                      builder: (_) => EditProjectDialog(project: project),
                    );
                    onResult?.call(res);
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

      return store;
    }

    testWidgets('pre-populates all existing project properties', (tester) async {
      await pumpDialog(tester);

      expect(find.text('Edit project'), findsOneWidget);
      expect(find.text('Original Project'), findsOneWidget);
      expect(find.text('orig_key'), findsOneWidget);
      expect(find.text('Original Description'), findsOneWidget);
      expect(find.text('https://github.com/test/repo'), findsOneWidget);
      expect(find.text('https://docs.test.com'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('closes when Cancel is pressed', (tester) async {
      await pumpDialog(tester);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Edit project'), findsNothing);
    });

    testWidgets('updates all fields including labor toggle and returns updated project', (
      tester,
    ) async {
      Project? dialogResult;
      final store = await pumpDialog(
        tester,
        onResult: (res) => dialogResult = res as Project?,
      );

      final textFields = find.byType(TextFormField);
      // Index 0: displayName, Index 1: key (read-only), Index 2: description, Index 3: projectUrl, Index 4: docuUrl
      await tester.enterText(textFields.at(0), 'New Name');
      await tester.enterText(textFields.at(2), 'New Description');
      await tester.enterText(textFields.at(3), 'https://github.com/new/repo');
      await tester.enterText(textFields.at(4), 'https://docs.new.com');
      final switchFinder = find.byType(SwitchListTile);
      await tester.ensureVisible(switchFinder);
      await tester.pumpAndSettle();
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit project'), findsNothing);
      expect(dialogResult?.displayName, 'New Name');
      expect(dialogResult?.description, 'New Description');
      expect(dialogResult?.projectUrl, 'https://github.com/new/repo');
      expect(dialogResult?.docuUrl, 'https://docs.new.com');
      expect(dialogResult?.labor, isTrue);

      final updatedInStore = store.state.projects.first;
      expect(updatedInStore.displayName, 'New Name');
      expect(updatedInStore.description, 'New Description');
      expect(updatedInStore.projectUrl, 'https://github.com/new/repo');
      expect(updatedInStore.docuUrl, 'https://docs.new.com');
      expect(updatedInStore.labor, isTrue);
    }, skip: true);

    testWidgets('sets optional fields to null when cleared', (tester) async {
      Project? dialogResult;
      final store = await pumpDialog(
        tester,
        onResult: (res) => dialogResult = res as Project?,
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(2), ''); // description
      await tester.enterText(textFields.at(3), ''); // projectUrl
      await tester.enterText(textFields.at(4), ''); // docuUrl
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit project'), findsNothing);
      expect(dialogResult?.description, isNull);
      expect(dialogResult?.projectUrl, isNull);
      expect(dialogResult?.docuUrl, isNull);

      final updatedInStore = store.state.projects.first;
      expect(updatedInStore.description, isNull);
      expect(updatedInStore.projectUrl, isNull);
      expect(updatedInStore.docuUrl, isNull);
    });
  }, skip: true);
}
