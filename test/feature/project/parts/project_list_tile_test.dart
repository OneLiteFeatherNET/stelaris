import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/project/parts/project_list_tile.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/l10n/app_localizations_delegates.dart';
import 'package:stelaris_models/stelaris_models.dart';

const _project = Project(id: 'p-1', displayName: 'Vulpes', key: 'vulpes');

Future<ColorScheme> _pump(WidgetTester tester, {required bool selected}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ProjectListTile(
          project: _project,
          isSelected: selected,
          onSelect: () {},
          onEdit: () {},
        ),
      ),
    ),
  );
  return Theme.of(tester.element(find.byType(ProjectListTile))).colorScheme;
}

Material _tileMaterial(WidgetTester tester) => tester.widget<Material>(
  find
      .descendant(
        of: find.byType(ProjectListTile),
        matching: find.byType(Material),
      )
      .first,
);

void main() {
  testWidgets('marks the selected project with a bar on the left', (
    tester,
  ) async {
    final colorScheme = await _pump(tester, selected: true);

    final material = _tileMaterial(tester);
    final border = material.shape! as Border;
    expect(border.left.color, colorScheme.primary);
    expect(border.left.width, 3);
    expect(material.color, isNot(Colors.transparent));
  });

  testWidgets('keeps the bar transparent when not selected', (tester) async {
    await _pump(tester, selected: false);

    final material = _tileMaterial(tester);
    final border = material.shape! as Border;
    expect(border.left.color, Colors.transparent);
    expect(
      border.left.width,
      3,
      reason: 'the same width keeps the content from shifting',
    );
    expect(material.color, Colors.transparent);
  });
}
