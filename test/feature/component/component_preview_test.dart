import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/component/component_preview.dart';
import 'package:stelaris/util/component_context.dart';

void main() {
  Future<void> pumpPreview(
    WidgetTester tester,
    ComponentPreview preview, {
    ThemeData? theme,
    double width = 400,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: SizedBox(width: width, child: preview),
          ),
        ),
      ),
    );
  }

  BoxDecoration decorationOf(WidgetTester tester) {
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(ComponentPreview),
            matching: find.byType(Container),
          )
          .first,
    );
    return container.decoration! as BoxDecoration;
  }

  testWidgets('renders the parsed text in the context color', (tester) async {
    await pumpPreview(
      tester,
      const ComponentPreview(
        text: '<gold>Epic',
        componentContext: ComponentContext.lore,
      ),
    );

    expect(find.text('Epic'), findsOneWidget);
    final rich = tester.widget<RichText>(find.byType(RichText));
    final spans = <TextSpan>[];
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.text == 'Epic') spans.add(span);
      return true;
    });
    expect(spans.single.style?.color, const Color(0xFFFFAA00));
    expect(spans.single.style?.fontStyle, FontStyle.normal);
  });

  testWidgets('shows the placeholder for empty text', (tester) async {
    await pumpPreview(
      tester,
      const ComponentPreview(
        text: '',
        componentContext: ComponentContext.itemName,
        placeholder: 'Not set',
      ),
    );

    expect(find.text('Not set'), findsOneWidget);
  });

  for (final theme in [ThemeData.light(), ThemeData.dark()]) {
    testWidgets(
      'uses the same gray surface in ${theme.brightness.name} theme',
      (tester) async {
        await pumpPreview(
          tester,
          const ComponentPreview(
            text: 'x',
            componentContext: ComponentContext.lore,
          ),
          theme: theme,
        );

        final decoration = decorationOf(tester);
        expect(decoration.color, previewBackground);
        final border = decoration.border! as Border;
        expect(border.top.color, previewBorder);
        expect(border.top.width, 1);
      },
    );
  }

  group('contrast halo', () {
    List<Shadow>? shadowsOf(WidgetTester tester, String text) {
      final rich = tester.widget<RichText>(find.byType(RichText));
      List<Shadow>? found;
      rich.text.visitChildren((span) {
        if (span is TextSpan && span.text == text) found = span.style?.shadows;
        return true;
      });
      return found;
    }

    Future<void> pumpText(WidgetTester tester, String text) {
      return pumpPreview(
        tester,
        ComponentPreview(text: text, componentContext: ComponentContext.lore),
      );
    }

    bool isLight(Color color) => color.computeLuminance() > 0.5;

    testWidgets('the default lore purple gets a light halo', (tester) async {
      await pumpText(tester, 'Lore');

      final shadows = shadowsOf(tester, 'Lore')!;
      expect(shadows, isNotEmpty);
      expect(shadows.every((shadow) => isLight(shadow.color)), isTrue);
    });

    testWidgets('dark blue gets a light halo', (tester) async {
      await pumpText(tester, '<dark_blue>Deep');

      final shadows = shadowsOf(tester, 'Deep')!;
      expect(shadows, isNotEmpty);
      expect(shadows.every((shadow) => isLight(shadow.color)), isTrue);
    });

    testWidgets('red gets a dark halo', (tester) async {
      await pumpText(tester, '<red>Hot');

      final shadows = shadowsOf(tester, 'Hot')!;
      expect(shadows, isNotEmpty);
      expect(shadows.every((shadow) => !isLight(shadow.color)), isTrue);
    });

    testWidgets('readable colors get no halo', (tester) async {
      await pumpText(tester, '<yellow>Sun<white>Snow');

      expect(shadowsOf(tester, 'Sun') ?? const [], isEmpty);
      expect(shadowsOf(tester, 'Snow') ?? const [], isEmpty);
    });

    testWidgets('each gradient letter gets its own halo', (tester) async {
      await pumpText(tester, '<gradient:dark_blue:yellow>ab</gradient>');

      expect(shadowsOf(tester, 'a'), isNotEmpty);
      expect(shadowsOf(tester, 'b') ?? const [], isEmpty);
    });
  });

  testWidgets('single line mode cuts long text without overflow', (
    tester,
  ) async {
    await pumpPreview(
      tester,
      ComponentPreview(
        text: '<gold>${'x' * 300}',
        componentContext: ComponentContext.lore,
        singleLine: true,
      ),
      width: 200,
    );

    expect(tester.takeException(), isNull);
    final rich = tester.widget<RichText>(find.byType(RichText));
    expect(rich.maxLines, 1);
    expect(rich.overflow, TextOverflow.ellipsis);
  });
}
