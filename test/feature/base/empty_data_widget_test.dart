import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/base/empty_data_widget.dart';

void main() {
  group('EmptyDataWidget', () {
    testWidgets('renders default empty widget', (tester) async {
      const widget = EmptyDataWidget();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: widget)),
      );

      // Find the widget
      final finder = find.byType(EmptyDataWidget);
      expect(finder, findsOneWidget);

      // Inspect the widget fields
      final emptyWidget = tester.widget<EmptyDataWidget>(finder);
      expect(emptyWidget.header, 'No data available');
      expect(emptyWidget.subHeader, 'Use the add button to add new data!');
      expect(emptyWidget.icon, Icons.auto_awesome);

      // Check the rendered content
      expect(find.text('No data available'), findsOneWidget);
      expect(find.text('Use the add button to add new data!'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('renders standard with custom header', (tester) async {
      const widget = EmptyDataWidget.standard(header: 'Wonderful Header');

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: widget)),
      );

      final finder = find.byType(EmptyDataWidget);
      expect(finder, findsOneWidget);

      final emptyWidget = tester.widget<EmptyDataWidget>(finder);
      expect(emptyWidget.header, 'Wonderful Header');
      expect(emptyWidget.subHeader, 'Use the add button to add new data!');
      expect(emptyWidget.icon, Icons.auto_awesome);

      expect(find.text('Wonderful Header'), findsOneWidget);
      expect(find.text('Use the add button to add new data!'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('renders standard with header and subheader', (tester) async {
      const widget = EmptyDataWidget.standard(
        header: 'Wonderful Header',
        subHeader: 'Sub header',
      );

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: widget)),
      );

      final finder = find.byType(EmptyDataWidget);
      expect(finder, findsOneWidget);

      final emptyWidget = tester.widget<EmptyDataWidget>(finder);
      expect(emptyWidget.header, 'Wonderful Header');
      expect(emptyWidget.subHeader, 'Sub header');
      expect(emptyWidget.icon, Icons.auto_awesome);

      expect(find.text('Wonderful Header'), findsOneWidget);
      expect(find.text('Sub header'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}
