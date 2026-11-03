import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/state/actions/expression/expression_function_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/expression/expression_preview_panel.dart';
import 'package:stelaris/feature/expression_function/expression_function_detail_page.dart';
import 'package:stelaris/feature/expression_function/expression_function_preview.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../support/fake_http_client_adapter.dart';
import '../../support/pump_until.dart';

const _double = ExpressionFunctionModel(
  uiName: 'Double',
  id: 'f1',
  projectId: 'p1',
  name: 'double_it',
  body: 'base * 2',
  parameters: [ExpressionVariable(name: 'base', testValue: '3')],
);

const _wide = Size(1400, 900);
const _narrow = Size(600, 900);

final _previewSlot = find.byKey(const ValueKey('expression_preview_slot'));
final _previewToggle = find.byKey(const Key('expression_preview_toggle'));
final _previewInput = find.descendant(
  of: find.byType(ExpressionFunctionPreview),
  matching: find.byType(TextField),
);

/// Answers the catalog and the evaluation, so no request leaves the test.
void _useFakeBackend() {
  ApiService().expressionFunctionApi.apiClient.dio.httpClientAdapter =
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

Future<Store<AppState>> _pumpDetail(
  WidgetTester tester,
  Size size, {
  String location = '/function/detail',
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  _useFakeBackend();

  final store = Store<AppState>(
    initialState: const AppState(selectedExpressionFunction: _double),
  );
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/function/detail',
        builder: (context, state) =>
            const Scaffold(body: ExpressionFunctionDetailPage()),
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

/// Fires the preview's debounce and waits for its result to show.
Future<void> _settlePreview(WidgetTester tester, {String until = '6'}) async {
  await pumpUntil(
    tester,
    action: () => tester.pump(expressionPreviewDebounce),
    done: () => find.text(until).evaluate().isNotEmpty,
  );
}

void main() {
  testWidgets('the preview sits beside the General tab on a wide screen', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    expect(_previewSlot, findsOneWidget);
    expect(find.byType(ExpressionFunctionPreview), findsOneWidget);
    expect(find.widgetWithText(Tab, 'Test'), findsNothing);
  });

  testWidgets(
    'the scrollbar beside the preview starts level with the content',
    (tester) async {
      await _pumpDetail(tester, _wide);
      await _settlePreview(tester);

      final pageScrollbar = find
          .descendant(
            of: find.byType(TabBarView),
            matching: find.byType(Scrollbar),
          )
          .first;
      expect(
        MediaQuery.paddingOf(tester.element(pageScrollbar)).top,
        16,
        reason: 'the scrollbar is inset like the content below the tab bar',
      );
      expect(
        find.descendant(of: _previewSlot, matching: pageScrollbar),
        findsNothing,
        reason: "it is the page's scrollbar, not the preview's",
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets('the toggle hides the preview', (tester) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    await tester.tap(_previewToggle);
    await tester.pumpAndSettle();

    expect(find.byType(ExpressionFunctionPreview), findsNothing);
  });

  testWidgets('the Parameters tab has no preview and no Preview toggle', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide);
    await _settlePreview(tester);

    await tester.tap(find.widgetWithText(Tab, 'Parameters'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpressionFunctionPreview), findsNothing);
    expect(_previewToggle, findsNothing);
  });

  testWidgets('an old link to the Test tab opens the General tab', (
    tester,
  ) async {
    await _pumpDetail(tester, _wide, location: '/function/detail?tab=test');
    await _settlePreview(tester);

    expect(find.byType(ExpressionFunctionPreview), findsOneWidget);
    expect(_previewToggle, findsOneWidget);
  });

  testWidgets('a value typed for a renamed parameter does not come back', (
    tester,
  ) async {
    final store = await _pumpDetail(tester, _wide);
    await _settlePreview(tester);
    await tester.enterText(_previewInput, '5');
    await tester.pump();

    Future<void> rename(String name) async {
      await tester.runAsync(
        () async => store.dispatch(
          UpdateExpressionFunctionAction(
            _double.copyWith(
              parameters: [ExpressionVariable(name: name, testValue: '3')],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await rename('other');
    await rename('base');
    await _settlePreview(tester);

    expect(
      find.descendant(of: _previewSlot, matching: find.text('3')),
      findsOneWidget,
      reason: 'the stored test value, not the one typed before',
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

    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(ExpressionFunctionPreview),
      ),
      findsOneWidget,
    );
  });
}
