import 'package:freezed_annotation/freezed_annotation.dart';

part 'expression_validation_model.freezed.dart';

part 'expression_validation_model.g.dart';

/// A problem the backend found in a formula. [start] is the 0-based index of
/// the first character and [end] the index after the last one.
@freezed
abstract class ExpressionValidationError with _$ExpressionValidationError {
  const factory ExpressionValidationError({
    required String message,
    required int start,
    required int end,
  }) = _ExpressionValidationError;

  factory ExpressionValidationError.fromJson(Map<String, dynamic> json) =>
      _$ExpressionValidationErrorFromJson(json);
}

/// What the backend made of a formula while it is typed: whether it parses,
/// where it does not, and which declared variables it reads.
///
/// The variable lists are empty when the formula does not parse. Names are as
/// the formula writes them, matched without regard to case.
@freezed
abstract class ExpressionValidation with _$ExpressionValidation {
  const factory ExpressionValidation({
    required bool valid,
    @Default([]) List<ExpressionValidationError> errors,
    @Default([]) List<String> usedVariables,
    @Default([]) List<String> undefinedVariables,
    @Default([]) List<String> unusedVariables,
  }) = _ExpressionValidation;

  factory ExpressionValidation.fromJson(Map<String, dynamic> json) =>
      _$ExpressionValidationFromJson(json);
}
