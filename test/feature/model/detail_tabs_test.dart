import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/model/detail_tabs.dart';

final List<DetailTab> _tabs = [
  DetailTab('general', (_) => 'General', formerIds: ['meta']),
  DetailTab('enchantments', (_) => 'Enchantments'),
  DetailTab('lore', (_) => 'Lore'),
];

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
      expect(await _indexAt(tester, '/items/detail?tab=lore'), 2);
    });

    testWidgets('the name is matched case-insensitively', (tester) async {
      expect(await _indexAt(tester, '/items/detail?tab=ENCHANTMENTS'), 1);
    });

    testWidgets('a former id gives the tab it was merged into', (tester) async {
      expect(await _indexAt(tester, '/items/detail?tab=meta'), 0);
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

    test('with a tab adds its id', () {
      expect(
        detailLocation('/fonts', DetailTab('characters', (_) => 'Characters')),
        '/fonts/detail?tab=characters',
      );
    });
  });
}
