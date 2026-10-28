import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/expression/expression_detail_page.dart';
import 'package:stelaris/feature/expression/expression_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/pump_until.dart';

const _double = ExpressionModel(
  uiName: 'Double',
  id: 'e1',
  projectId: 'p1',
  expression: 'a * 2',
  variables: [ExpressionVariable(name: 'a', testValue: '3')],
);

const _wide = Size(1200, 900);
const _narrow = Size(600, 900);

final _previewSlot = find.byKey(const ValueKey('expression_preview_slot'));
final _previewToggle = find.byKey(const Key('expression_preview_toggle'));

/// Answers the catalog and the evaluation, so no request leaves the test.
void _useFakeBackend() {
  ApiService().expressionApi.apiClient.dio.httpClientAdapter =
      FakeHttpClientAdapter((options) {
        if (options.path.endsWith('/catalog')) {
          return FakeHttpClientAdapter.response({
            'functions': <Object>[],
            'constants': <Object>[],
          });
        }
        return FakeHttpClientAdapter.response({'value': '6', 'type': 'NUMBER'});
      });
}

Future<void> _pumpDetail(WidgetTester tester, Size size) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  _useFakeBackend();

  final store = Store<AppState>(
    initialState: const AppState(selectedExpression: _double),
  );
  final router = GoRouter(
    initialLocation: '/expression/detail',
    routes: [
      GoRoute(
        path: '/expression/detail',
        builder: (context, state) =>
            const Scaffold(body: ExpressionDetailPage()),
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
  await tester.pump();
}

/// Fires the preview's debounce and waits for its result to show. The
/// preview is built on the General tab, so its timer has to run out before
/// the test ends.
Future<void> _settlePreview(WidgetTester tester) async {
  await pumpUntil(
    tester,
    action: () => tester.pump(expressionPreviewDebounce),
    done: () => find.text('6').evaluate().isNotEmpty,
  );
}

void main() {
  testWidgets('the preview sits beside the General tab on a wide screen', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    expect(_previewSlot, findsOneWidget);
    expect(find.byType(ExpressionPreview), findsOneWidget);
  });

  testWidgets('the toggle hides the preview and shows it again', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    await tester.tap(_previewToggle);
    await tester.pumpAndSettle();
    expect(find.byType(ExpressionPreview), findsNothing);

    await tester.tap(_previewToggle);
    await tester.pumpAndSettle();
    expect(find.byType(ExpressionPreview), findsOneWidget);
  });

  testWidgets('the Test tab has no preview beside it', (tester) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    await tester.tap(find.text('Test'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpressionPreview), findsNothing);
  });

  testWidgets('the Variables tab shows the preview beside it too', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    await tester.tap(find.widgetWithText(Tab, 'Variables'));
    await tester.pumpAndSettle();

    expect(_previewSlot, findsOneWidget);
  });

  testWidgets('the preview toggle is not in the tab bar row', (tester) async {
    await _pumpDetail(tester, _wide);

    expect(
      find.descendant(of: find.byType(TabBar), matching: _previewToggle),
      findsNothing,
      reason: 'the toggle is a page action, not a tab bar button',
    );
  });

  testWidgets('the toggle is selected while the preview is shown', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);
    expect(tester.widget<PageHeaderAction>(_previewToggle).selected, isTrue);

    await tester.tap(_previewToggle);
    await tester.pumpAndSettle();

    expect(tester.widget<PageHeaderAction>(_previewToggle).selected, isFalse);
  });

  testWidgets('the page keeps the Test tab after the preview leaves', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    await tester.tap(find.text('Test'));
    await tester.pumpAndSettle();

    expect(
      find.text('Evaluate'),
      findsOneWidget,
      reason: 'the tab change must not snap back to an earlier tab',
    );
  });

  testWidgets('a narrow screen opens the preview as a bottom sheet', (
    tester,
  ) async {
    await _pumpDetail(tester, _narrow);
    expect(_previewSlot, findsNothing, reason: 'no room beside the tabs');

    await tester.tap(_previewToggle);
    await tester.pump();
    await _settlePreview(tester);

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(ExpressionPreview),
      ),
      findsOneWidget,
    );
  });
}
