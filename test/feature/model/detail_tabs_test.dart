import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';

const List<String> _tabs = ['General', 'Meta', 'Enchantments', 'Lore'];

/// The index [initialTabIndex] picks at [location].
Future<int> _indexAt(WidgetTester tester, String location) async {
  late int index;
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/items/detail',
        builder: (context, state) {
          index = initialTabIndex(context, _tabs);
          return const SizedBox();
        },
      ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pumpAndSettle();
  return index;
}

void main() {
  group('initialTabIndex', () {
    testWidgets('a named tab gives its index', (tester) async {
      expect(await _indexAt(tester, '/items/detail?tab=lore'), 3);
    });

    testWidgets('the name is matched case-insensitively', (tester) async {
      expect(await _indexAt(tester, '/items/detail?tab=ENCHANTMENTS'), 2);
    });

    testWidgets('no parameter gives the first tab', (tester) async {
      expect(await _indexAt(tester, '/items/detail'), 0);
    });

    testWidgets('an unknown name gives the first tab', (tester) async {
      expect(await _indexAt(tester, '/items/detail?tab=nonsense'), 0);
    });
  });

  group('detailLocation', () {
    test('without a tab is the plain detail route', () {
      expect(detailLocation('/items'), '/items/detail');
    });

    test('with a tab adds it, lowercased', () {
      expect(
        detailLocation('/fonts', 'FontFace'),
        '/fonts/detail?tab=fontface',
      );
    });
  });
}
