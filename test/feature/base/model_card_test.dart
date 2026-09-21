import 'dart:ui' show PointerDeviceKind;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/button/delete_model_button.dart';
import 'package:stelaris/feature/base/model_card.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris_models/stelaris_models.dart';

void main() {
  group('ModelCard Widget Tests', () {
    const defaultShape = RoundedRectangleBorder(
      side: BorderSide(color: Colors.blue),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );

    const testModel = ItemModel(id: 'item-1', uiName: 'Test Item');
    const testProject = Project(
      id: 'proj-1',
      displayName: 'Project',
      key: 'proj',
    );

    Widget createWidget({
      bool selected = false,
      RoundedRectangleBorder selectedCardShape = defaultShape,
      ItemModel? rawModel,
      VoidCallback? onTap,
    }) {
      final model = rawModel ?? testModel;
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.amber,
          ),
        ),
        home: Scaffold(
          body: ModelCard<ItemModel>(
            selected: selected,
            selectedCardShape: selectedCardShape,
            mapToDeleteDialog: (model) => [TextSpan(text: model.uiName)],
            mapToDeleteSuccessfully: (_) => true,
            mapToDataModelItem: (model) => Text(model.uiName),
            rawModel: model,
            nameSelector: (model) => model.uiName,
            keySelector: (model) => model.key ?? '',
            copyDialogTitle: 'Copy item',
            mapToCopySuccessfully: (_, _) => true,
            projects: const [testProject],
            currentProject: testProject,
            onTap: onTap,
          ),
        ),
      );
    }

    final cardInkWell = find.byKey(const Key('model_card_inkwell'));

    testWidgets('renders title item and delete button', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.byType(DeleteModelButton<ItemModel>), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(cardInkWell, findsOneWidget);
    });

    testWidgets('triggers onTap callback when card is clicked', (tester) async {
      var tapped = false;
      await tester.pumpWidget(createWidget(onTap: () => tapped = true));

      await tester.tap(cardInkWell);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('applies selectedCardShape when selected is true', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(selected: true));

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, isNull);
      expect(card.shape, defaultShape);
    });

    testWidgets('does not apply shape when selected is false', (tester) async {
      await tester.pumpWidget(createWidget(selected: false));

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, isNull);
      expect(card.shape, isNull);
    });

    testWidgets('InkWell has hoverColor and matching borderRadius', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(onTap: () {}));

      final inkWell = tester.widget<InkWell>(cardInkWell);
      expect(inkWell.hoverColor, equals(Colors.amber.withValues(alpha: 0.1)));
      expect(
        inkWell.borderRadius,
        equals(const BorderRadius.all(Radius.circular(12))),
      );
      expect(inkWell.splashFactory, equals(NoSplash.splashFactory));
    });

    testWidgets('mouse hover triggers InkWell hover effect', (tester) async {
      await tester.pumpWidget(createWidget(onTap: () {}));

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(cardInkWell));
      await tester.pump();

      // Verify widget remains mounted and renders without errors during hover
      expect(find.text('Test Item'), findsOneWidget);
    });
  });
}
