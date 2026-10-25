import 'package:flutter/material.dart';
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
      // Expressions have no glyph in that font yet, so they use Material's
      // function icon; the font itself is not changed for them.
      for (final entry in NavigationEntry.values.where(
        (entry) => entry != NavigationEntry.expression,
      )) {
        expect(entry.data.fontFamily, 'StelarisIcons', reason: entry.name);
        expect(entry.selected.fontFamily, 'StelarisIcons', reason: entry.name);
      }
    });

    test('expressions use the Material function icon', () {
      expect(NavigationEntry.expression.data, Icons.functions_outlined);
      expect(NavigationEntry.expression.selected, Icons.functions);
    });
  });
}
