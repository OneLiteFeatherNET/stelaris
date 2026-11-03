import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/expression/expression_detail_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  test('the tabs are general and variables, in that order', () {
    expect(
      [for (final tab in ExpressionDetailPage.tabs) tab.id],
      ['general', 'variables'],
    );
  });

  test('the tabs are labelled General and Variables', () {
    final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

    expect(
      [for (final tab in ExpressionDetailPage.tabs) tab.label(l10n)],
      ['General', 'Variables'],
    );
  });
}
