import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/model_card_frame.dart';

void main() {
  Future<void> pumpFrame(
    WidgetTester tester, {
    Widget? trailing,
    String? summary,
    String? footerText,
    VoidCallback? onTap,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: ModelCardFrame(
            content: const Text('Ruby'),
            trailing: trailing,
            summary: summary,
            footerIcon: Icons.schedule,
            footerText: footerText,
            onTap: onTap,
          ),
        ),
      ),
    ),
  );

  testWidgets('shows the content and the trailing widget in the header', (
    tester,
  ) async {
    await pumpFrame(tester, trailing: const Text('2 missing'));

    expect(find.text('Ruby'), findsOneWidget);
    expect(find.text('2 missing'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('2 missing')).dx,
      greaterThan(tester.getTopLeft(find.text('Ruby')).dx),
    );
  });

  testWidgets('shows the summary line when there is one', (tester) async {
    await pumpFrame(tester, summary: 'Boss drop');

    expect(find.text('Boss drop'), findsOneWidget);
  });

  testWidgets('shows the footer below a divider only with a text', (
    tester,
  ) async {
    await pumpFrame(tester);

    expect(find.byType(Divider), findsNothing);
    expect(find.byIcon(Icons.schedule), findsNothing);

    await pumpFrame(tester, footerText: 'Model · 5 min ago');

    expect(find.byType(Divider), findsOneWidget);
    expect(find.byIcon(Icons.schedule), findsOneWidget);
    expect(find.text('Model · 5 min ago'), findsOneWidget);
  });

  testWidgets('a tap calls onTap', (tester) async {
    var tapped = false;
    await pumpFrame(tester, onTap: () => tapped = true);

    await tester.tap(find.byKey(const Key('model_grid_card_inkwell')));

    expect(tapped, isTrue);
  });
}
