import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:stelaris/api/model/problem_detail.dart';

const double snackBarWidth = 550;

/// The [InfoBarFactory] class is a factory class that creates [SnackBar]s
/// for information, success, and error feedback.
class InfoBarFactory {
  static final InfoBarFactory _reference = InfoBarFactory._internal();

  InfoBarFactory._internal();

  factory InfoBarFactory() {
    return _reference;
  }

  /// Creates a standard neutral info [SnackBar] with the given text and width.
  SnackBar create(String text, [double width = snackBarWidth]) {
    return SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 2),
      width: width,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
    );
  }

  /// Semantic alias for creating a standard info [SnackBar].
  SnackBar createInfo(String text, [double width = snackBarWidth]) =>
      create(text, width);

  /// Creates a success [SnackBar] with green background and a check icon.
  SnackBar createSuccess(
    String text, {
    double width = snackBarWidth,
    Duration duration = const Duration(seconds: 3),
  }) {
    return SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade700,
      duration: duration,
      width: width,
      elevation: 2,
      behavior: SnackBarBehavior.floating,
    );
  }

  /// Creates a [SnackBar] displaying the given [ProblemDetail].
  ///
  /// Uses amber/warning styling for validation errors and client input issues (400, 409),
  /// and red/error styling for server and connection failures (5xx, timeouts).
  SnackBar createError(ProblemDetail problem, [double width = snackBarWidth]) {
    final message = problem.displayMessage;
    final hasValidationErrors = problem.errors.isNotEmpty;

    final String textToDisplay;
    if (hasValidationErrors) {
      final errorsList =
          problem.errors.map((e) => '• ${e.field}: ${e.message}').join('\n');
      textToDisplay = '$message\n$errorsList';
    } else if (problem.code != null &&
        problem.code!.isNotEmpty &&
        problem.code != 'UNKNOWN_ERROR') {
      textToDisplay = '$message (${problem.code})';
    } else {
      textToDisplay = message;
    }

    if (problem.isValidationError) {
      return createWarning(textToDisplay, width: width);
    }
    return createErrorText(textToDisplay, width: width);
  }

  /// Creates a warning [SnackBar] with amber background and a warning icon.
  SnackBar createWarning(
    String text, {
    double width = snackBarWidth,
    Duration duration = const Duration(seconds: 4),
  }) {
    return SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.amber.shade900,
      duration: duration,
      width: width,
      elevation: 2,
      behavior: SnackBarBehavior.floating,
    );
  }

  /// Creates an error [SnackBar] with red background and an error icon.
  SnackBar createErrorText(
    String text, {
    double width = snackBarWidth,
    Duration duration = const Duration(seconds: 4),
  }) {
    return SnackBar(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade800,
      duration: duration,
      width: width,
      elevation: 2,
      behavior: SnackBarBehavior.floating,
    );
  }

}

/// Convenience extensions on [BuildContext] for showing feedback snackbars.
extension ScaffoldMessengerContextExtension on BuildContext {
  /// Shows a floating success [SnackBar] with green background and check icon.
  void showSuccessSnackBar(String text) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(InfoBarFactory().createSuccess(text));
  }

  /// Shows a floating warning [SnackBar] with amber background and warning icon.
  void showWarningSnackBar(String text) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(InfoBarFactory().createWarning(text));
  }

  /// Shows a floating info [SnackBar].
  void showInfoSnackBar(String text) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(InfoBarFactory().create(text));
  }

  /// Shows a floating error [SnackBar], converting [error] into a [ProblemDetail] if needed.
  void showErrorSnackBar(Object error) {
    final ProblemDetail problem;
    if (error is ProblemDetail) {
      problem = error;
    } else if (error is DioException) {
      problem = ProblemDetail.fromDioException(error);
    } else {
      problem = ProblemDetail(
        title: 'Error',
        status: 500,
        detail: error.toString(),
      );
    }

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(InfoBarFactory().createError(problem));
  }
}
