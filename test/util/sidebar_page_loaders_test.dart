import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/util/routes.dart';

void main() {
  test('every sidebar page can be preloaded', () {
    expect(sidebarPageLoaders.keys, {
      for (final entry in NavigationEntry.values) entry.route,
      for (final entry in AssetNavigationEntry.values) entry.route,
      for (final entry in BuildNavigationEntry.values) entry.route,
    });
  });
}
