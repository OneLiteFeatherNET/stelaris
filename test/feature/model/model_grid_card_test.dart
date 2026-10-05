import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/feature/base/button/model_actions_menu.dart';
import 'package:stelaris/feature/model/model_copy.dart';
import 'package:stelaris/feature/model/model_grid_card.dart';
import 'package:stelaris/feature/model/model_notes.dart';
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

    Widget createWidget({
      VoidCallback? onTap,
      TestModel? rawModel,
      ModelCopy<TestModel>? copy,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Scaffold(
          body: ModelGridCard<TestModel>(
            rawModel: rawModel ?? model,
            mapToDataModelItem: (m) => Text(m.name),
            deleteTitle: 'Delete test model',
            mapToDeleteSuccessfully: (_) => true,
            nameSelector: (m) => m.name,
            keySelector: (m) => m.internalId.toString(),
            notes: ModelNotes(
              read: (m) => m.notes,
              update: (_, _) => throw UnimplementedError(),
            ),
            projectKey: 'proj',
            onTap: onTap,
            copy: copy,
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

    testWidgets('shows only the first line of the notes', (tester) async {
      await tester.pumpWidget(
        createWidget(
          rawModel: TestModel(
            internalId: 1,
            name: 'Test Attribute',
            modificationDate: now,
            notes: '\n  Boss drop  \nOnly given out in the nether',
          ),
        ),
      );

      expect(find.text('Boss drop'), findsOneWidget);
      expect(find.textContaining('nether'), findsNothing);
    });

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
    testWidgets('offers "Copy" in the menu when copying is enabled', (tester) async {
      await tester.pumpWidget(
        createWidget(
          copy: ModelCopy<TestModel>(
            title: (l10n) => l10n.dialog_item_copy,
            action: (_, _) => throw UnimplementedError(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('has no "Copy" without copying enabled', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Copy'), findsNothing);
    });
  });
}
