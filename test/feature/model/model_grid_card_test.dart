import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/feature/base/button/model_actions_menu.dart';
import 'package:stelaris/feature/model/model_grid_card.dart';
import 'package:stelaris/l10n/app_localizations.dart';

import '../../test_model.dart';

void main() {
  group('ModelGridCard', () {
    final now = DateTime.now();
    final model = TestModel(
      internalId: 1,
      name: 'Test Attribute',
      modificationDate: now,
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
            deleteTitle: 'Delete test model',
            mapToDeleteSuccessfully: (_) => true,
            nameSelector: (m) => m.name,
            keySelector: (m) => m.internalId.toString(),
            projectKey: 'proj',
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets(
      'renders content, info button, delete button, and relative time',
      (tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.text('Test Attribute'), findsOneWidget);
        expect(find.byType(ModelActionsMenu<TestModel>), findsOneWidget);
        expect(find.byType(DeleteModelButton<TestModel>), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
        expect(find.textContaining('Edited'), findsOneWidget);
      },
    );

    testWidgets('triggers onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(createWidget(onTap: () => tapped = true));

      await tester.tap(find.byKey(const Key('model_grid_card_inkwell')));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('delete dialog asks for the model name', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byType(DeleteModelButton<TestModel>));
      await tester.pumpAndSettle();

      expect(find.text('Delete test model'), findsOneWidget);
      expect(find.text('proj:1'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is SelectableText &&
              w.textSpan!.toPlainText() ==
                  'To confirm, type "Test Attribute" in the box below',
        ),
        findsOneWidget,
      );
    });
  });
}
