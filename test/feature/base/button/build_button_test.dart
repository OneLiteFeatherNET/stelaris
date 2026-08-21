import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/feature/base/button/build_button.dart';
import 'package:stelaris/feature/build/build_dialog.dart';

void main() {
  testWidgets('BuildButton opens BuildDialog on tap', (WidgetTester tester) async {
    final store = Store<AppState>(initialState: AppState.fromJson({}));

    await tester.pumpWidget(
      StoreProvider<AppState>(
        store: store,
        child: const MaterialApp(
          home: Scaffold(body: BuildButton()),
        ),
      ),
    );

    // Verify button is rendered
    expect(find.byIcon(Icons.build_outlined), findsOneWidget);

    // Initially, the dialog should be closed
    expect(find.byType(BuildDialog), findsNothing);

    // Tap the build button
    await tester.tap(find.byIcon(Icons.build_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify that tapping opened the BuildDialog
    expect(find.byType(BuildDialog), findsOneWidget);
  });
}
