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
      'uses the same dark surface in ${theme.brightness.name} theme',
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

  group('text shadow', () {
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

    testWidgets('the default lore purple keeps its color and gets its shadow', (
      tester,
    ) async {
      await pumpText(tester, 'Lore');

      final shadow = shadowsOf(tester, 'Lore')!.single;
      // #AA00AA at a quarter of its brightness.
      expect(shadow.color.r, closeTo(0xAA / 255 / 4, 0.001));
      expect(shadow.color.g, 0);
      expect(shadow.color.b, closeTo(0xAA / 255 / 4, 0.001));
      expect(shadow.offset, const Offset(1, 1));
      expect(shadow.blurRadius, 0);
    });

    testWidgets('light colors get a shadow, not a glow', (tester) async {
      await pumpText(tester, '<yellow>Sun<white>Snow');

      for (final text in ['Sun', 'Snow']) {
        final shadow = shadowsOf(tester, text)!.single;
        expect(shadow.blurRadius, 0, reason: text);
        expect(shadow.offset, isNot(Offset.zero), reason: text);
      }
    });

    for (final (tag, text) in [('black', 'Night'), ('dark_blue', 'Deep')]) {
      testWidgets('$tag gets a thin light outline instead', (tester) async {
        await pumpText(tester, '<$tag>$text');

        final shadow = shadowsOf(tester, text)!.single;
        expect(shadow.color.computeLuminance(), greaterThan(0.5));
        expect(shadow.offset, Offset.zero);
      });
    }

    testWidgets('each gradient letter gets its own shadow', (tester) async {
      await pumpText(tester, '<gradient:dark_blue:yellow>ab</gradient>');

      expect(shadowsOf(tester, 'a')!.single.offset, Offset.zero);
      expect(shadowsOf(tester, 'b')!.single.offset, const Offset(1, 1));
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
