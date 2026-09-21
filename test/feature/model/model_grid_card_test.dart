import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/feature/model/model_grid_card.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

import '../../test_model.dart';

void main() {
  group('ModelGridCard', () {
    final now = DateTime.now();
    final model = TestModel(
      internalId: 1,
      name: 'Test Attribute',
      modificationDate: now,
    );
    const testProject = Project(
      id: 'proj-1',
      displayName: 'Project',
      key: 'proj',
    );

    Widget createWidget({VoidCallback? onTap}) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Scaffold(
          body: ModelGridCard<TestModel>(
            rawModel: model,
            mapToDataModelItem: (m) => Text(m.name),
            mapToDeleteDialog: (m) => [TextSpan(text: m.name)],
            mapToDeleteSuccessfully: (_) => true,
            nameSelector: (m) => m.name,
            keySelector: (m) => m.internalId.toString(),
            copyDialogTitle: 'Copy',
            mapToCopySuccessfully: (_, _) => true,
            projects: const [testProject],
            currentProject: testProject,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('renders content, delete button, and relative time', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Test Attribute'), findsOneWidget);
      expect(find.byType(DeleteModelButton<TestModel>), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.textContaining('Edited'), findsOneWidget);
    });

    testWidgets('triggers onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(createWidget(onTap: () => tapped = true));

      await tester.tap(find.byKey(const Key('model_grid_card_inkwell')));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
