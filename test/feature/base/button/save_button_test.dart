import 'dart:async';

import 'package:async_redux/async_redux.dart';
import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/button/save_button.dart';
import 'package:stelaris/util/constants.dart';

void main() {
  testWidgets('SaveButton without text renders icon only and triggers callback',
          (WidgetTester tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SaveButton(
                callback: () {
                  pressed = true;
                },
              ),
            ),
          ),
        );

        // Check that the icon is there
        expect(find.byWidget(saveIcon), findsOneWidget);

        // Since no text is provided, ensure no label is shown
        expect(find.byType(Text), findsNothing);

        // Tap the button
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Verify callback triggered
        expect(pressed, isTrue);
      });

  testWidgets('SaveButton with text renders label and triggers callback',
          (WidgetTester tester) async {
        var pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SaveButton(
                text: 'Save Changes',
                callback: () {
                  pressed = true;
                },
              ),
            ),
          ),
        );

        // Verify the text is shown
        expect(find.text('Save Changes'), findsOneWidget);

        // Verify the icon is present
        expect(find.byWidget(saveIcon), findsOneWidget);

        // Tap the button
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pump();

        // Verify callback triggered
        expect(pressed, isTrue);
      });

  testWidgets('SaveButton shows loading indicator while async callback is running',
      (WidgetTester tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SaveButton(
            callback: () => completer.future,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byWidget(saveIcon), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    // While completer is unresolved, progress indicator should be shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byWidget(saveIcon), findsNothing);

    completer.complete();
    await tester.pump();

    // After completion, icon returns
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byWidget(saveIcon), findsOneWidget);
  });

  testWidgets('SaveButton displays success snackbar on completion when successMessage is set',
      (WidgetTester tester) async {
    final completer = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SaveButton(
            successMessage: 'Saved successfully',
            callback: () => completer.future,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.text('Saved successfully'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, Colors.green.shade700);
  });

  testWidgets('SaveButton catches error and displays error snackbar with ProblemDetail',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SaveButton(
            callback: () async {
              throw DioException(
                requestOptions: RequestOptions(path: '/test'),
                response: Response(
                  requestOptions: RequestOptions(path: '/test'),
                  statusCode: 400,
                  data: {
                    'title': 'Validation Failed',
                    'status': 400,
                    'detail': 'Item name cannot be empty',
                    'code': 'VALIDATION_FAILED',
                  },
                ),
                type: DioExceptionType.badResponse,
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Item name cannot be empty'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, Colors.amber.shade900);
    // Button should not be stuck in loading
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byWidget(saveIcon), findsOneWidget);
  });

  testWidgets(
      'SaveButton does not trigger callback or show snackbar if formKey validation fails',
      (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();
    var callbackCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
                SaveButton(
                  formKey: formKey,
                  successMessage: 'Saved successfully',
                  callback: () {
                    callbackCalled = true;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(callbackCalled, isFalse);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets(
      'SaveButton executes callback and shows success snackbar if formKey validation succeeds',
      (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();
    var callbackCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: 'Valid input',
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
                SaveButton(
                  formKey: formKey,
                  successMessage: 'Saved successfully',
                  callback: () {
                    callbackCalled = true;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(callbackCalled, isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Saved successfully'), findsOneWidget);
  });

  testWidgets(
      'SaveButton does not display success snackbar when callback returns false',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SaveButton(
            successMessage: 'Saved successfully',
            callback: () async => false,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets(
      'SaveButton displays success snackbar when dispatchAndWait returns ActionStatus.isCompletedOk',
      (WidgetTester tester) async {
    final store = Store<AppState>(initialState: const AppState());

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => SaveButton(
                successMessage: 'Saved successfully',
                callback: () => context.dispatchAndWait(_SuccessfulTestAction()),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Saved successfully'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets(
      'SaveButton displays error snackbar and does not show success when ActionStatus fails',
      (WidgetTester tester) async {
    final store = Store<AppState>(initialState: const AppState());

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => SaveButton(
                successMessage: 'Saved successfully',
                callback: () => context.dispatchAndWait(_FailingTestAction()),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Must NOT show success message
    expect(find.text('Saved successfully'), findsNothing);
    // Must show error snackbar
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Save failed in test'), findsOneWidget);
  });

  testWidgets(
      'SaveButton does not display success snackbar when dispatch is aborted',
      (WidgetTester tester) async {
    final store = Store<AppState>(initialState: const AppState());

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => SaveButton(
                successMessage: 'Saved successfully',
                callback: () => context.dispatchAndWait(_AbortedTestAction()),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
  });
}

class _SuccessfulTestAction extends ReduxAction<AppState> {
  @override
  AppState reduce() => state;
}

class _FailingTestAction extends ReduxAction<AppState> {
  @override
  AppState reduce() => throw const UserException('Save failed in test');
}

class _AbortedTestAction extends ReduxAction<AppState> {
  @override
  bool abortDispatch() => true;

  @override
  AppState reduce() => state;
}


