import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/item/enchantment/dialog/item_enchantment_update_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/constants.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:vulpes_data/enchantment.dart';

class _FakeEnchantment implements Enchantment {
  @override
  String get displayName => 'Sharpness';

  @override
  String get key => 'sharpness';

  @override
  int get maxLevel => 5;
}

void main() {
  Future<void> pumpDialog(WidgetTester tester, ItemEnchantmentDto dto) {
    return tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ItemEnchantmentUpdateDialog(
            enchantment: _FakeEnchantment(),
            dto: dto,
          ),
        ),
      ),
    );
  }

  group('ItemEnchantmentUpdateDialog', () {
    testWidgets('accepts levels above the max level for unsafe entries', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        const ItemEnchantmentDto(name: 'sharpness', level: 10, unsafe: true),
      );
      await tester.pump();

      expect(find.text('The maximum is 5'), findsNothing);
    });

    testWidgets('rejects levels above the max level for safe entries', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        const ItemEnchantmentDto(name: 'sharpness', level: 10),
      );
      await tester.pump();

      expect(find.text('The maximum is 5'), findsOneWidget);
    });

    testWidgets('limits the input to the digits of a short', (tester) async {
      await pumpDialog(
        tester,
        const ItemEnchantmentDto(name: 'sharpness', level: 1, unsafe: true),
      );

      await tester.enterText(find.byType(TextFormField), '1234567');
      await tester.pump();

      expect(find.text('12345'), findsOneWidget);
      expect(find.text('The maximum is $maxEnchantmentLevel'), findsNothing);

      await tester.enterText(find.byType(TextFormField), '99999');
      await tester.pump();

      expect(find.text('The maximum is $maxEnchantmentLevel'), findsOneWidget);
    });
  });
}
