import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/feature/asset/models/model_revisions_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../../support/fake_http_client_adapter.dart';
import '../../../support/pump_until.dart';

const _ruby = AssetModel(
  id: 'm1',
  projectId: 'p-1',
  displayName: 'Ruby',
  key: 'vulpes:item/ruby',
  kind: AssetKind.MODEL,
  fileName: 'ruby.json',
  contentType: 'application/json',
  size: 64,
  sha1: 'sha-2',
);

final _revisions = {
  'items': [
    {'id': 'r-2', 'number': 2, 'sha1': 'sha-2', 'size': 64, 'current': true},
    {
      'id': 'r-1',
      'number': 1,
      'sha1': 'sha-1',
      'size': 32,
      'comment': 'First try',
    },
  ],
  'totalItems': 2,
  'totalPages': 1,
  'currentPage': 0,
  'pageSize': 50,
};

/// Answers the revision list, the content of a revision and a restore.
List<RequestOptions> _serve({int restoreStatus = 200}) {
  final requests = <RequestOptions>[];
  ApiService().assetApi.apiClient.dio.httpClientAdapter = FakeHttpClientAdapter(
    (options) {
      requests.add(options);
      final path = options.uri.path;
      if (path.endsWith('/content')) {
        return ResponseBody.fromBytes(utf8.encode('old'), 200);
      }
      if (path.endsWith('/restore')) {
        return restoreStatus == 200
            ? FakeHttpClientAdapter.response(
                _ruby.copyWith(sha1: 'sha-3').toJson(),
              )
            : FakeHttpClientAdapter.response({
                'title': 'Precondition failed',
                'status': restoreStatus,
              }, statusCode: restoreStatus);
      }
      return FakeHttpClientAdapter.response(_revisions);
    },
  );
  return requests;
}

/// Opens the dialog from a button and records what it popped.
Future<List<RevisionsResult?>> _open(
  WidgetTester tester, {
  void Function(List<int> bytes, String fileName)? saveFile,
}) async {
  final results = <RevisionsResult?>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => results.add(
              await showDialog<RevisionsResult>(
                context: context,
                builder: (_) => ModelRevisionsDialog(
                  asset: _ruby,
                  saveFile: saveFile ?? (_, _) {},
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await pumpUntil(
    tester,
    action: () async {},
    done: () => find.text('Version 1').evaluate().isNotEmpty,
  );
  return results;
}

Finder _restoreOf(int number) => find.descendant(
  of: find.byKey(ValueKey('model_revision_$number')),
  matching: find.byTooltip('Restore this version'),
);

void main() {
  testWidgets('lists the versions newest first with the current marked', (
    tester,
  ) async {
    _serve();
    await _open(tester);

    final second = tester.getTopLeft(find.text('Version 2'));
    final first = tester.getTopLeft(find.text('Version 1'));
    expect(second.dy, lessThan(first.dy));
    expect(find.text('Current'), findsOneWidget);
    expect(find.textContaining('First try'), findsOneWidget);
    expect(_restoreOf(2), findsNothing);
    expect(_restoreOf(1), findsOneWidget);
  });

  testWidgets('downloads a version under its numbered file name', (
    tester,
  ) async {
    final requests = _serve();
    final saved = <(String, String)>[];
    await _open(
      tester,
      saveFile: (bytes, fileName) => saved.add((utf8.decode(bytes), fileName)),
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('model_revision_1')),
        matching: find.byTooltip('Download this version'),
      ),
    );
    await pumpUntil(tester, action: () async {}, done: () => saved.isNotEmpty);

    expect(saved, [('old', 'ruby.v1.json')]);
    expect(
      requests.last.uri.path,
      endsWith('/project/p-1/asset/m1/revision/r-1/content'),
    );
  });

  testWidgets('restores a version after asking and pops the result', (
    tester,
  ) async {
    final requests = _serve();
    final results = await _open(tester);

    await tester.tap(_restoreOf(1));
    await tester.pumpAndSettle();
    expect(find.text('Restore version 1?'), findsOneWidget);

    await tester.tap(find.text('Restore'));
    await pumpUntil(
      tester,
      action: () async {},
      done: () => results.isNotEmpty,
    );

    final restore = requests.last;
    expect(restore.method, 'POST');
    expect(restore.uri.path, endsWith('/asset/m1/revision/r-1/restore'));
    expect(restore.headers['If-Match'], '"sha-2"');
    final result = results.single;
    expect(result, isA<RevisionRestored>());
    expect((result! as RevisionRestored).revision.number, 1);
  });

  testWidgets('cancelling the question restores nothing', (tester) async {
    final requests = _serve();
    await _open(tester);

    await tester.tap(_restoreOf(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(requests.where((r) => r.method == 'POST'), isEmpty);
    expect(find.text('Version 1'), findsOneWidget);
  });

  testWidgets('a restore after a change by someone else pops a conflict', (
    tester,
  ) async {
    _serve(restoreStatus: 412);
    final results = await _open(tester);

    await tester.tap(_restoreOf(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore'));
    await pumpUntil(
      tester,
      action: () async {},
      done: () => results.isNotEmpty,
    );

    expect(results.single, isA<RevisionConflict>());
  });
}
