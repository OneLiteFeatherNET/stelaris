import 'package:flutter_test/flutter_test.dart';

/// Pumps until [pending] turns false, then settles.
///
/// On the web, dio finishes even a faked request in several real-async
/// steps that testWidgets' fake-async zone doesn't run on its own, so this
/// alternates frames with a little real time. A few frames run in any case,
/// for requests a page only starts after its first frame.
Future<void> settleRequests(
  WidgetTester tester,
  bool Function() pending,
) async {
  for (var i = 0; i < 20 && (i < 3 || pending()); i++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
  await tester.pumpAndSettle();
}
