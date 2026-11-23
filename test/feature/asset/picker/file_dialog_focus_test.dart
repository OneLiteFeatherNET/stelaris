import 'package:flutter_test/flutter_test.dart';
import 'package:stelaris/feature/asset/picker/file_dialog_focus.dart';

void main() {
  var time = DateTime(2026);

  setUp(() => FileDialogFocus.now = () => time);
  tearDown(FileDialogFocus.reset);

  test('has no focus before a dialog opened', () {
    expect(FileDialogFocus.hadFocus, isFalse);
  });

  test('has the focus while a dialog is open', () {
    FileDialogFocus.opened();
    time = time.add(const Duration(minutes: 5));

    expect(FileDialogFocus.hadFocus, isTrue);
  });

  test('keeps the focus for the grace after closing', () {
    FileDialogFocus.opened();
    FileDialogFocus.closed();

    time = time.add(FileDialogFocus.grace - const Duration(milliseconds: 1));
    expect(FileDialogFocus.hadFocus, isTrue);

    time = time.add(const Duration(milliseconds: 1));
    expect(FileDialogFocus.hadFocus, isFalse);
  });

  test('an extra close does not count below zero', () {
    FileDialogFocus.closed();
    FileDialogFocus.closed();
    time = time.add(FileDialogFocus.grace);
    FileDialogFocus.opened();

    expect(FileDialogFocus.hadFocus, isTrue);
  });
}
