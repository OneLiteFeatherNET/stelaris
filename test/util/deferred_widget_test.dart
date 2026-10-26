import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/deferred_widget.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  testWidgets('shows the placeholder until the library has loaded', (
    tester,
  ) async {
    final load = Completer<void>();
    await tester.pumpWidget(
      host(
        DeferredWidget(
          loader: () => load.future,
          builder: () => const Text('loaded'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('loaded'), findsNothing);

    load.complete();
    await tester.pump();

    expect(find.text('loaded'), findsOneWidget);
  });

  testWidgets('a failed load shows an error instead of building', (
    tester,
  ) async {
    var built = false;
    await tester.pumpWidget(
      host(
        DeferredWidget(
          loader: () => Future.error(DeferredLoadException('offline')),
          builder: () {
            built = true;
            return const Text('loaded');
          },
        ),
      ),
    );
    await tester.pump();

    expect(built, isFalse);
    expect(
      find.text(
        'This page could not be loaded. Check your connection, then try again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('retrying calls the loader again and builds once it succeeds', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        DeferredWidget(
          loader: () {
            calls++;
            return calls == 1
                ? Future.error(DeferredLoadException('offline'))
                : Future.value();
          },
          builder: () => const Text('loaded'),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Try again'));
    // One frame starts the new load, the next one shows its result.
    await tester.pump();
    await tester.pump();

    expect(calls, 2);
    expect(find.text('loaded'), findsOneWidget);
  });
}
