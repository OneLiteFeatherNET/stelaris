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
}
