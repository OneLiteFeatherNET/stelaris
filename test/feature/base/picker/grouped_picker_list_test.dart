import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/picker/grouped_picker_list.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, List<String>> groups, {
  ValueChanged<String>? onGroup,
  String emptyText = 'nothing',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 560,
          height: 480,
          child: GroupedPickerList<String, String>(
            groups: groups,
            groupLabel: (group) => group,
            groupTooltip: (label) => 'only $label',
            headerKey: (group) => ValueKey('h_$group'),
            itemKey: (entry) => ValueKey('i_$entry'),
            itemBuilder: (context, entry) =>
                ListTile(title: Text(entry), onTap: () {}),
            emptyText: emptyText,
            onGroup: onGroup,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _top(WidgetTester tester, String key) =>
    tester.getTopLeft(find.byKey(ValueKey(key))).dy;

void main() {
  group('grouped picker list', () {
    testWidgets('lists a header per group before its entries', (tester) async {
      await _pump(tester, {
        'A': ['a1', 'a2'],
        'B': ['b1'],
      });

      final tops = [
        for (final key in ['h_A', 'i_a1', 'i_a2', 'h_B', 'i_b1'])
          _top(tester, key),
      ];
      expect(tops, orderedEquals([...tops]..sort()));
      expect(tops.toSet(), hasLength(5));
    });

    testWidgets('shows the empty text without groups', (tester) async {
      await _pump(tester, {});

      expect(find.text('nothing'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('a header reports its group on tap', (tester) async {
      String? tapped;
      await _pump(tester, {
        'A': ['a1'],
        'B': ['b1'],
      }, onGroup: (group) => tapped = group);

      expect(find.byTooltip('only B'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('h_B')));
      expect(tapped, 'B');
    });

    testWidgets('a filtered header is not clickable', (tester) async {
      await _pump(tester, {
        'A': ['a1'],
      });

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('h_A')),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
      expect(find.byTooltip('only A'), findsNothing);
    });

    testWidgets('scrolling does not repaint the whole list', (tester) async {
      await _pump(tester, {
        'A': [for (var i = 0; i < 200; i++) 'a$i'],
      });

      final list = find.byType(ListView);
      tester.binding.handlePointerEvent(
        PointerScrollEvent(
          position: tester.getCenter(list),
          scrollDelta: const Offset(0, 100),
        ),
      );

      // The Material around the list holds the ink of the rows unless each
      // row has its own: then it would repaint all rows on every frame.
      final around = find
          .ancestor(of: list, matching: find.byType(Material))
          .first;
      expect(tester.renderObject(around).debugNeedsPaint, isFalse);
      await tester.pump();
    });
  });
}
