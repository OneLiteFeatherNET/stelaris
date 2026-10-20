import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/chips/info_chip.dart';
import 'package:stelaris/feature/model/model_card_content.dart';

void main() {
  group('ModelCardContent', () {
    Widget createWidget({String? modelKey}) {
      return MaterialApp(
        home: Scaffold(
          body: ModelCardContent(
            name: 'Test Model',
            modelKey: modelKey,
            projectKey: 'manis',
          ),
        ),
      );
    }

    testWidgets('shows the name and the namespaced key', (tester) async {
      await tester.pumpWidget(createWidget(modelKey: 'test'));

      expect(find.text('Test Model'), findsOneWidget);
      expect(find.text('manis:test'), findsOneWidget);
    });

    testWidgets('shows no key chip without a key', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Test Model'), findsOneWidget);
      expect(find.byType(InfoChip), findsNothing);
    });

    testWidgets('shows no key chip for an empty key', (tester) async {
      await tester.pumpWidget(createWidget(modelKey: ''));

      expect(find.byType(InfoChip), findsNothing);
    });
  });
}
