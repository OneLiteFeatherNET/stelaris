import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/dialogs/model_create_dialog.dart';
import 'package:stelaris/l10n/app_localizations.dart';

void main() {
  group('ModelCreateDialog Widget Tests', () {
    Future<void> pumpDialog(
      WidgetTester tester, {
      required void Function(String name, String key) onSubmit,
      String projectNamespace = 'my_project',
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ModelCreateDialog(
                    title: 'Create Item',
                    projectNamespace: projectNamespace,
                    onSubmit: onSubmit,
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders title, input fields, initial preview and buttons', (tester) async {
      await pumpDialog(
        tester,
        onSubmit: (name, key) {},
      );

      expect(find.text('Create Item'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('NamespacedKey Preview'), findsOneWidget);
      expect(find.text('my_project:<key>'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('uses explicit projectNamespace if provided', (tester) async {
      await pumpDialog(
        tester,
        projectNamespace: 'custom_ns',
        onSubmit: (name, key) {},
      );

      expect(find.text('custom_ns:<key>'), findsOneWidget);
    });

    testWidgets('typing in key field updates preview in real time', (tester) async {
      await pumpDialog(
        tester,
        onSubmit: (name, key) {},
      );

      final keyField = find.byType(TextFormField).at(1);
      await tester.enterText(keyField, 'ruby_sword');
      await tester.pump();

      expect(find.text('my_project:ruby_sword'), findsOneWidget);
    });

    testWidgets('validates required fields on create click', (tester) async {
      String? submittedName;
      String? submittedKey;

      await pumpDialog(
        tester,
        onSubmit: (name, key) {
          submittedName = name;
          submittedKey = key;
        },
      );

      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(submittedName, isNull);
      expect(submittedKey, isNull);
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Key is required'), findsOneWidget);
    });

    testWidgets('validates invalid key characters', (tester) async {
      await pumpDialog(
        tester,
        onSubmit: (name, key) {},
      );

      final nameField = find.byType(TextFormField).at(0);
      final keyField = find.byType(TextFormField).at(1);

      await tester.enterText(nameField, 'My Sword');
      await tester.enterText(keyField, 'invalid:key');
      await tester.pump();

      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(find.text('Colons (:) are not allowed in the key part'), findsOneWidget);
    });

    testWidgets('calls onSubmit with name and key when valid', (tester) async {
      String? submittedName;
      String? submittedKey;

      await pumpDialog(
        tester,
        onSubmit: (name, key) {
          submittedName = name;
          submittedKey = key;
        },
      );

      final nameField = find.byType(TextFormField).at(0);
      final keyField = find.byType(TextFormField).at(1);

      await tester.enterText(nameField, 'Emerald Sword');
      await tester.enterText(keyField, 'emerald_sword');
      await tester.pump();

      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(submittedName, 'Emerald Sword');
      expect(submittedKey, 'emerald_sword');
    });

    testWidgets('cancel button closes dialog', (tester) async {
      await pumpDialog(
        tester,
        onSubmit: (name, key) {},
      );

      expect(find.text('Create Item'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Create Item'), findsNothing);
    });
  });
}
