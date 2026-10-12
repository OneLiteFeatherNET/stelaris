import 'package:flutter_test/flutter_test.dart';

/// Runs [action] in a real async zone and pumps until [done] holds.
///
/// Requests through Dio, also to a fake adapter, run on real timers that
/// don't move in the fake time of a widget test. A fixed wait was too short
/// on slower machines, so this waits for the result itself, up to
/// [timeout].
Future<void> pumpUntil(
  WidgetTester tester, {
  required Future<void> Function() action,
  required bool Function() done,
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.runAsync(() async {
    await action();
    final end = DateTime.now().add(timeout);
    while (true) {
      // Moves the fake time too, so animations like a closing dialog end.
      await tester.pump(const Duration(milliseconds: 20));
      if (done()) return;
      if (DateTime.now().isAfter(end)) {
        fail('the expected result did not show up within $timeout');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  });
  await tester.pumpAndSettle();
}
