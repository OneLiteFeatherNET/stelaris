import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/asset/models/asset_model_actions.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

const _gem = AssetModel(
  id: 't1',
  projectId: 'p-1',
  displayName: 'Gem',
  key: 'vulpes:block/gem',
  kind: AssetKind.TEXTURE,
  fileName: 'gem.png',
  contentType: 'image/png',
  size: 64,
  sha1: 'sha-1',
);

Future<void> _pump(WidgetTester tester, {required bool readOnly}) async {
  tester.view.physicalSize = const Size(1400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AssetModelActions(
          model: _gem,
          pickFile: () async => null,
          saveFile: (_, _) {},
          onChanged: () async {},
          readOnly: readOnly,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('read only hides update', (tester) async {
    await _pump(tester, readOnly: true);

    expect(find.byKey(const Key('model_update')), findsNothing);
    expect(find.byKey(const Key('model_notes')), findsOneWidget);
    expect(find.byKey(const Key('model_info')), findsOneWidget);
    expect(find.byKey(const Key('model_revisions')), findsOneWidget);
    expect(find.byKey(const Key('model_download')), findsOneWidget);
  });

  testWidgets('update is offered by default', (tester) async {
    await _pump(tester, readOnly: false);

    expect(find.byKey(const Key('model_update')), findsOneWidget);
  });
}
