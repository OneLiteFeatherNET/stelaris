import 'package:async_redux/async_redux.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/command_palette/backend_command.dart';

class _Succeeds extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async => state.copyWith(branches: ['main']);
}

class _Throws extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async => throw Exception('backend down');
}

class _Swallows extends ReduxAction<AppState> {
  @override
  Future<AppState?> reduce() async => state.copyWith(branches: null);
}

Future<BuildContext> _pump(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(
    StoreProvider<AppState>(
      store: Store<AppState>(initialState: const AppState(branches: ['old'])),
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      ),
    ),
  );
  return context;
}

void main() {
  testWidgets('a completing action shows the success bar', (tester) async {
    final context = await _pump(tester);

    await runBackendCommand(context, _Succeeds(), success: 'ok', failure: 'no');
    await tester.pump();

    expect(find.text('ok'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });

  testWidgets('a throwing action shows the error bar', (tester) async {
    final context = await _pump(tester);

    await runBackendCommand(context, _Throws(), success: 'ok', failure: 'no');
    await tester.pump();

    expect(find.text('no'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('a throwing action leaves the previous state in place', (
    tester,
  ) async {
    final context = await _pump(tester);
    final store = StoreProvider.backdoorInheritedWidget<AppState>(context);

    await runBackendCommand(context, _Throws(), success: 'ok', failure: 'no');

    expect(store.state.branches, ['old']);
  });

  testWidgets('the outcome check turns a swallowed error into a failure', (
    tester,
  ) async {
    final context = await _pump(tester);

    await runBackendCommand(
      context,
      _Swallows(),
      success: 'ok',
      failure: 'no',
      outcome: (before, after) => after.branches == null
          ? BackendOutcome.failure
          : BackendOutcome.success,
    );
    await tester.pump();

    expect(find.text('no'), findsOneWidget);
  });

  testWidgets('a neutral outcome shows the neutral message', (tester) async {
    final context = await _pump(tester);

    await runBackendCommand(
      context,
      _Succeeds(),
      success: 'ok',
      failure: 'no',
      neutral: 'nothing new',
      outcome: (_, _) => BackendOutcome.neutral,
    );
    await tester.pump();

    expect(find.text('nothing new'), findsOneWidget);
  });
}
