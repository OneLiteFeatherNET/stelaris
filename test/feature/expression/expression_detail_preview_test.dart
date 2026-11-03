import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/expression/expression_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/page_header.dart';
import 'package:stelaris/feature/expression/expression_detail_page.dart';
import 'package:stelaris/feature/expression/expression_preview.dart';
import 'package:stelaris/feature/expression/expression_preview_panel.dart';
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
final _previewInput = find.descendant(
  of: find.byType(ExpressionPreview),
  matching: find.byType(TextField),
);

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

Future<Store<AppState>> _pumpDetail(WidgetTester tester, Size size) async {
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
  return store;
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

  testWidgets('the Variables tab has no preview and no Preview toggle', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    await tester.tap(find.widgetWithText(Tab, 'Variables'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpressionPreview), findsNothing);
    expect(_previewToggle, findsNothing);

    await tester.tap(find.widgetWithText(Tab, 'General'));
    await tester.pumpAndSettle();
    expect(_previewToggle, findsOneWidget, reason: 'back on General');
    await _settlePreview(tester);
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

  testWidgets('there is no Test tab, the preview takes its place', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    expect(find.widgetWithText(Tab, 'Test'), findsNothing);
  });

  testWidgets('a value typed into the preview stays across a tab change', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    await tester.enterText(_previewInput, '5');
    await tester.pump();
    await tester.tap(find.widgetWithText(Tab, 'Variables'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'General'));
    await tester.pumpAndSettle();
    await _settlePreview(tester);

    expect(
      find.descendant(of: _previewSlot, matching: find.text('5')),
      findsOneWidget,
    );
  });

  testWidgets('a value typed for a renamed variable does not come back', (
    tester,
  ) async {
    final store = await _pumpDetail(tester, _wide);
    await _settlePreview(tester);
    await tester.enterText(_previewInput, '5');
    await tester.pump();

    Future<void> rename(String name) async {
      await tester.runAsync(
        () async => store.dispatch(
          UpdateExpressionAction(
            _double.copyWith(
              variables: [ExpressionVariable(name: name, testValue: '3')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await rename('b');
    await rename('a');
    await _settlePreview(tester);

    expect(
      find.descendant(of: _previewSlot, matching: find.text('3')),
      findsOneWidget,
      reason: 'the stored test value, not the one typed before',
    );
  });

  testWidgets('a value typed in beside the tabs is in the bottom sheet too', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);
    await tester.enterText(_previewInput, '5');
    await tester.pump();

    tester.view.physicalSize = _narrow;
    await tester.pumpAndSettle();
    await tester.tap(_previewToggle);
    await tester.pump();
    await _settlePreview(tester);

    expect(
      find.descendant(of: find.byType(BottomSheet), matching: find.text('5')),
      findsOneWidget,
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
