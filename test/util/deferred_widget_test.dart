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

  testWidgets('builds straight away once the same loader has loaded before', (
    tester,
  ) async {
    Future<void> loader() => Future.value();

    await tester.pumpWidget(
      host(DeferredWidget(loader: loader, builder: () => const Text('first'))),
    );
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);

    await tester.pumpWidget(
      host(
        DeferredWidget(
          key: UniqueKey(),
          loader: loader,
          builder: () => const Text('second'),
        ),
      ),
    );

    // The very first frame of the new instance already shows the page, with
    // no placeholder flashing in between.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('second'), findsOneWidget);
  });

  testWidgets('fades the page in once a first load finishes', (tester) async {
    final load = Completer<void>();
    await tester.pumpWidget(
      host(
        DeferredWidget(
          loader: () => load.future,
          builder: () => const Text('loaded'),
        ),
      ),
    );

    load.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final opacity = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.text('loaded'),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(opacity.opacity.value, inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('keeps the page state when an ancestor rebuilds after the first '
      'load', (tester) async {
    final load = Completer<void>();
    Future<void> loader() => load.future;
    var inits = 0;
    Widget frame(String title) => host(
      Column(
        children: [
          Text(title),
          Expanded(
            child: DeferredWidget(
              loader: loader,
              builder: () => _InitCounter(onInit: () => inits++),
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(frame('before'));
    load.complete();
    await tester.pumpAndSettle();
    await tester.pumpWidget(frame('after'));
    await tester.pumpAndSettle();

    expect(inits, 1);
  });

  testWidgets('gives a freshly loaded page the same constraints as a revisit', (
    tester,
  ) async {
    final load = Completer<void>();
    Future<void> loader() => load.future;
    final seen = <BoxConstraints>[];
    Widget page() => LayoutBuilder(
      builder: (context, constraints) {
        seen.add(constraints);
        return const SizedBox();
      },
    );

    await tester.pumpWidget(
      host(DeferredWidget(loader: loader, builder: page)),
    );
    load.complete();
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      host(DeferredWidget(key: UniqueKey(), loader: loader, builder: page)),
    );

    expect(seen, hasLength(greaterThan(1)));
    expect(seen.toSet(), hasLength(1));
  });

  testWidgets('a preloaded page builds straight away on its first visit', (
    tester,
  ) async {
    Future<void> loader() => Future.value();
    await DeferredWidget.preload(loader);

    await tester.pumpWidget(
      host(DeferredWidget(loader: loader, builder: () => const Text('page'))),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('page'), findsOneWidget);
  });

  testWidgets('a failed preload is left for the visit to retry', (
    tester,
  ) async {
    var calls = 0;
    Future<void> loader() {
      calls++;
      return calls == 1
          ? Future.error(DeferredLoadException('offline'))
          : Future.value();
    }

    await DeferredWidget.preload(loader);
    await tester.pumpWidget(
      host(DeferredWidget(loader: loader, builder: () => const Text('page'))),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('page'), findsOneWidget);
  });
}

class _InitCounter extends StatefulWidget {
  const _InitCounter({required this.onInit});

  final VoidCallback onInit;

  @override
  State<_InitCounter> createState() => _InitCounterState();
}

class _InitCounterState extends State<_InitCounter> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
