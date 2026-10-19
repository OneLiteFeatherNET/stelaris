import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/util/navigation.dart';

void main() {
  test('matches a section route exactly', () {
    expect(entryForLocation('/items'), NavigationEntry.items);
  });

  test('matches nested routes of a section', () {
    expect(entryForLocation('/items/detail'), NavigationEntry.items);
    expect(entryForLocation('/fonts/detail'), NavigationEntry.font);
  });

  test('does not match a mere prefix of another word', () {
    expect(entryForLocation('/itemsfoo'), isNull);
  });

  test('returns null outside the sections', () {
    expect(entryForLocation('/projects'), isNull);
  });

  test('matches a project-scoped section below its project', () {
    expect(
      entryForLocation('/projects/p/attributes'),
      NavigationEntry.attributes,
    );
    expect(
      entryForLocation('/projects/p/attributes/a'),
      NavigationEntry.attributes,
    );
  });

  group('sectionLocation', () {
    test('puts a project-scoped section below its project', () {
      expect(
        sectionLocation(NavigationEntry.attributes, 'p'),
        '/projects/p/attributes',
      );
    });

    test('is the project list for a project-scoped section without one', () {
      expect(sectionLocation(NavigationEntry.attributes, null), '/projects');
      expect(sectionLocation(NavigationEntry.attributes, ''), '/projects');
    });

    test('leaves the other sections at their own route', () {
      expect(sectionLocation(NavigationEntry.items, 'p'), '/items');
      expect(sectionLocation(NavigationEntry.items, null), '/items');
    });
  });

  group('sectionPath', () {
    test('drops the project a location sits below', () {
      expect(sectionPath('/projects/p/attributes'), '/attributes');
      expect(sectionPath('/projects/p/attributes/a'), '/attributes/a');
    });

    test('leaves other locations alone', () {
      expect(sectionPath('/projects'), '/projects');
      expect(sectionPath('/projects/p'), '/projects/p');
      expect(sectionPath('/items/detail'), '/items/detail');
    });
  });

  group('icons', () {
    test('each section has distinct outline and filled icons', () {
      for (final entry in NavigationEntry.values) {
        expect(entry.data, isNot(entry.selected), reason: entry.name);
      }
    });

    test('no two sections share an icon', () {
      final icons = [
        for (final entry in NavigationEntry.values) ...[
          entry.data,
          entry.selected,
        ],
      ];
      expect(icons.toSet(), hasLength(icons.length));
    });

    test('all icons come from the StelarisIcons font', () {
      for (final entry in NavigationEntry.values) {
        expect(entry.data.fontFamily, 'StelarisIcons', reason: entry.name);
        expect(entry.selected.fontFamily, 'StelarisIcons', reason: entry.name);
      }
    });
  });
}
