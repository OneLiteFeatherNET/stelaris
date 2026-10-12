import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/sound/card/sound_card_button.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  testWidgets('is a tonal button without a style of its own', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SoundCardButton(
            source: SoundFileSource(
              name: 'step',
              volume: 1,
              pitch: 1,
              attenuationDistance: 16,
              preload: false,
              type: 'file',
              weight: 1,
            ),
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.style, isNull);
    expect(find.byType(ElevatedButton), findsNothing);
  });
}
