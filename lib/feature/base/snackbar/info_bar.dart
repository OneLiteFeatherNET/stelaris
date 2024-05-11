import 'package:flutter/material.dart';

const double snackBarWidth = 550;

/// The [InfoBarFactory] class is a factory class that creates a [SnackBar] with a given text.
/// The created [SnackBar] has a width of [snackBarWidth] and a duration of 2 seconds.
class InfoBarFactory {

  static final InfoBarFactory _reference = InfoBarFactory._internal();

  InfoBarFactory._internal();

  factory InfoBarFactory() {
    return _reference;
  }

  /// Creates a [SnackBar] with the given text and width.
  SnackBar create(String text, [double width = snackBarWidth]) {
    return SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 2),
      width: width,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
    );
  }
}
