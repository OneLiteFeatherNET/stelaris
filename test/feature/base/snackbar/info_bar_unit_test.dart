import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/feature/base/snackbar/info_bar.dart';

void main() {
  group('InfoBarFactory Unit Tests', () {
    late InfoBarFactory factory;

    setUp(() {
      // Since it's a singleton, getting an instance is always the same
      factory = InfoBarFactory();
    });

    test('factory constructor returns the same instance (singleton check)', () {
      final factory1 = InfoBarFactory();
      final factory2 = InfoBarFactory();
      expect(identical(factory1, factory2), isTrue);
      expect(identical(factory1, factory), isTrue);
    });

    test('create method returns a SnackBar with correct default properties', () {
      const String testText = 'Hello World';
      final SnackBar snackBar = factory.create(testText);

      // Check content
      expect(snackBar.content, isA<Text>());
      expect((snackBar.content as Text).data, equals(testText));

      // Check duration
      expect(snackBar.duration, equals(const Duration(seconds: 2)));

      // Check width (default)
      expect(snackBar.width, equals(snackBarWidth)); // Using the const from info_bar.dart

      // Check other properties
      expect(snackBar.elevation, equals(0));
      expect(snackBar.behavior, equals(SnackBarBehavior.floating));
    });

    test('create method returns a SnackBar with specified width', () {
      const String testText = 'Custom Width Test';
      const double customWidth = 300;
      final SnackBar snackBar = factory.create(testText, customWidth);

      // Check content
      expect((snackBar.content as Text).data, equals(testText));

      // Check width (custom)
      expect(snackBar.width, equals(customWidth));

      // Check other properties remain as default
      expect(snackBar.duration, equals(const Duration(seconds: 2)));
      expect(snackBar.elevation, equals(0));
      expect(snackBar.behavior, equals(SnackBarBehavior.floating));
    });

    test('create method handles empty text string', () {
      const String testText = '';
      final SnackBar snackBar = factory.create(testText);

      expect((snackBar.content as Text).data, equals(testText));
      expect(snackBar.width, equals(snackBarWidth));
    });

    test('createInfo returns same SnackBar as create', () {
      const String text = 'Info message';
      final SnackBar snackBar = factory.createInfo(text);

      expect(snackBar.content, isA<Text>());
      expect((snackBar.content as Text).data, equals(text));
      expect(snackBar.width, equals(snackBarWidth));
    });

    test('createSuccess returns green SnackBar with check icon', () {
      const String text = 'Saved successfully';
      final SnackBar snackBar = factory.createSuccess(text);

      expect(snackBar.content, isA<Row>());
      expect(snackBar.backgroundColor, equals(Colors.green.shade700));
      expect(snackBar.behavior, equals(SnackBarBehavior.floating));
      final row = snackBar.content as Row;
      expect(row.children.whereType<Icon>().first.icon, equals(Icons.check_circle_outline));
    });

    test('createErrorText returns styled error SnackBar', () {
      const String text = 'Error occurred';
      final SnackBar snackBar = factory.createErrorText(text);

      expect(snackBar.content, isA<Row>());
      expect(snackBar.backgroundColor, equals(Colors.red.shade800));
      expect(snackBar.behavior, equals(SnackBarBehavior.floating));
      expect(snackBar.duration, equals(const Duration(seconds: 4)));
    });

    test('createWarning returns styled amber SnackBar with warning icon', () {
      const String text = 'Warning occurred';
      final SnackBar snackBar = factory.createWarning(text);

      expect(snackBar.content, isA<Row>());
      expect(snackBar.backgroundColor, equals(Colors.amber.shade900));
      expect(snackBar.behavior, equals(SnackBarBehavior.floating));
      final row = snackBar.content as Row;
      expect(row.children.whereType<Icon>().first.icon, equals(Icons.warning_amber_rounded));
    });

    test('createError uses amber for validation errors and red for server errors', () {
      final validationProblem = ProblemDetail.fromJson({
        'title': 'Validation Failed',
        'status': 400,
        'detail': 'Invalid input',
        'code': 'VALIDATION_FAILED',
        'errors': [
          {'field': 'name', 'message': 'Must not be empty'},
        ],
      });

      final SnackBar validationSnackBar = factory.createError(validationProblem);
      expect(validationSnackBar.content, isA<Row>());
      final row = validationSnackBar.content as Row;
      final flexible = row.children.whereType<Flexible>().first;
      final textWidget = flexible.child as Text;
      expect(textWidget.data, contains('Invalid input'));
      expect(textWidget.data, contains('name: Must not be empty'));
      expect(validationSnackBar.backgroundColor, equals(Colors.amber.shade900));
      expect(row.children.whereType<Icon>().first.icon, equals(Icons.warning_amber_rounded));

      final serverProblem = const ProblemDetail(
        title: 'Server Error',
        status: 500,
        detail: 'Database connection failed',
      );

      final SnackBar serverSnackBar = factory.createError(serverProblem);
      expect(serverSnackBar.backgroundColor, equals(Colors.red.shade800));
      final serverRow = serverSnackBar.content as Row;
      expect(serverRow.children.whereType<Icon>().first.icon, equals(Icons.error_outline));
    });
  });
}



