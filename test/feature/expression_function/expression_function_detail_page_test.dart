import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/expression_function/expression_function_detail_page.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  test(
    'the tabs are general, parameters, test and interface, in that order',
    () {
      expect(
        [for (final tab in ExpressionFunctionDetailPage.tabs) tab.id],
        ['general', 'parameters', 'test', 'interface'],
      );
    },
  );

  test('the tabs are labelled General, Parameters, Test and Interface', () {
    final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

    expect(
      [for (final tab in ExpressionFunctionDetailPage.tabs) tab.label(l10n)],
      ['General', 'Parameters', 'Test', 'Interface'],
    );
  });
}
