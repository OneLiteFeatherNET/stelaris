import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/feature/component/syntax_guide_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/component_context.dart';

void main() {
  Future<void> pumpGuide(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SyntaxGuideDialog(componentContext: ComponentContext.lore),
        ),
      ),
    );
  }

  testWidgets('shows every example written out and rendered', (tester) async {
    await pumpGuide(tester);

    final previews = tester
        .widgetList<ComponentPreview>(find.byType(ComponentPreview))
        .toList();
    expect(previews, hasLength(5));
    for (final preview in previews) {
      expect(find.text(preview.text), findsOneWidget);
      expect(preview.componentContext, ComponentContext.lore);
    }
  });

  testWidgets('explains the tags in the app language', (tester) async {
    await pumpGuide(tester);

    expect(find.text('MiniMessage tags'), findsOneWidget);
    expect(find.text('A gradient over two or more colors.'), findsOneWidget);
  });
}
