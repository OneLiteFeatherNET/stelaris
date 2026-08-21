import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}

