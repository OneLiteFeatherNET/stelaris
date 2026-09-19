import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/routes.dart';

void main() {
  group('buildDetailSlideTransition', () {
    late AnimationController controller;

    setUp(() {
      controller = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildFrame() {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) => buildDetailSlideTransition(
            context,
            controller,
            const AlwaysStoppedAnimation(0),
            const Text('Detail content'),
          ),
        ),
      );
    }

    testWidgets('starts off-screen to the right at animation value 0', (tester) async {
      controller.value = 0;
      await tester.pumpWidget(buildFrame());

      final slide = tester.widget<SlideTransition>(find.byType(SlideTransition));
      expect(slide.position.value, const Offset(1, 0));
      expect(find.text('Detail content'), findsOneWidget);
    });

    testWidgets('settles at its natural position at animation value 1', (tester) async {
      controller.value = 1;
      await tester.pumpWidget(buildFrame());

      final slide = tester.widget<SlideTransition>(find.byType(SlideTransition));
      expect(slide.position.value, Offset.zero);
      expect(find.text('Detail content'), findsOneWidget);
    });

    testWidgets('fades in alongside the slide', (tester) async {
      controller.value = 0;
      await tester.pumpWidget(buildFrame());

      final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fade.opacity.value, 0);

      controller.value = 1;
      await tester.pump();

      final fadeAfter = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fadeAfter.opacity.value, 1);
    });

    testWidgets('stays invisible in the early part of the slide, so content does not '
        'appear fully arrived while still visibly moving', (tester) async {
      controller.value = 0.2;
      await tester.pumpWidget(buildFrame());

      final slide = tester.widget<SlideTransition>(find.byType(SlideTransition));
      final fade = tester.widget<FadeTransition>(find.byType(FadeTransition));

      expect(slide.position.value, isNot(const Offset(1, 0)));
      expect(fade.opacity.value, 0);
    });
  });
}
