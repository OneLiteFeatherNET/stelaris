import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/model_grid.dart';

void main() {
  Future<void> pumpGrid(
    WidgetTester tester, {
    required double width,
    int count = 5,
    VoidCallback? onLoadMore,
    bool hasMore = false,
    bool isLoadingMore = false,
  }) {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModelGrid<int>(
            items: List.generate(count, (index) => index),
            itemBuilder: (context, item) =>
                Text('card $item', key: ValueKey(item)),
            onLoadMore: onLoadMore,
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
          ),
        ),
      ),
    );
  }

  /// How many cards share the row of the first one.
  int columns(WidgetTester tester, int count) {
    final top = tester.getTopLeft(find.byKey(const ValueKey(0))).dy;
    return [
      for (var index = 0; index < count; index++)
        if (tester.getTopLeft(find.byKey(ValueKey(index))).dy == top) index,
    ].length;
  }

  testWidgets('fits as many columns as cards of 320 px', (tester) async {
    await pumpGrid(tester, width: 700);

    expect(ModelGrid.columnsFor(700), 2);
    expect(columns(tester, 5), 2);
  });

  testWidgets('shows at most four columns', (tester) async {
    await pumpGrid(tester, width: 2000);

    expect(columns(tester, 5), 4);
  });

  testWidgets('a narrow grid has one column', (tester) async {
    await pumpGrid(tester, width: 300);

    expect(columns(tester, 2), 1);
  });

  testWidgets('cards are as high as the card height', (tester) async {
    await pumpGrid(tester, width: 700);

    final first = tester.getTopLeft(find.byKey(const ValueKey(0))).dy;
    final below = tester.getTopLeft(find.byKey(const ValueKey(2))).dy;
    expect(below - first, 148 + ModelGrid.spacing);
  });

  testWidgets('shows a footer while more items load', (tester) async {
    await pumpGrid(
      tester,
      width: 700,
      onLoadMore: () {},
      hasMore: true,
      isLoadingMore: true,
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('asks for more items when scrolled near the end', (tester) async {
    var asked = 0;
    await pumpGrid(
      tester,
      width: 700,
      count: 60,
      onLoadMore: () => asked++,
      hasMore: true,
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await tester.pump(const Duration(milliseconds: 300));

    expect(asked, 1);
  });

  testWidgets('asks for nothing without more items', (tester) async {
    var asked = 0;
    await pumpGrid(tester, width: 700, count: 60, onLoadMore: () => asked++);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -4000));
    await tester.pump(const Duration(milliseconds: 300));

    expect(asked, 0);
  });
}
