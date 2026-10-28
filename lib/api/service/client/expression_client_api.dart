import 'package:dio/dio.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Client API for expressions: the CRUD endpoints every model has, plus
/// `evaluate`, which runs an expression against test values.
class ExpressionClientApi extends BaseApi<ExpressionModel> {
  /// Creates an instance of [ExpressionClientApi].
  ///
  /// The base endpoint for expressions is set to 'expression'.
  ExpressionClientApi({required super.apiClient})
    : super(
        endpoint: 'expression',
        fromJson: ExpressionModel.fromJson,
        toJson: (model) => model.toJson(),
      );

  /// Loads the catalog of [projectId]: the functions, operators and constants
  /// the backend supports, and the functions the project defines. The request
  /// goes to `project/{projectId}/expression-catalog`.
  Future<ExpressionCatalog> catalog(String projectId) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/$projectId/expression-catalog',
    );
    final result = await apiClient.dio.getUri<Map<String, dynamic>>(uri);
    return ExpressionCatalog.fromJson(result.data!);
  }

  /// Evaluates [expression] in the project [projectId] with the values of
  /// [variables], and returns what it came to.
  ///
  /// The request goes to `project/{projectId}/expression/evaluate`. A variable
  /// without a test value is sent as an empty string.
  ///
  /// A rejected expression or variable (HTTP 400) throws a [ProblemDetail]
  /// whose `errors` name the field that failed, `expression` or
  /// `variables.<name>`. Any other failure is rethrown as it came.
  Future<ExpressionResult> evaluate(
    String projectId,
    String expression,
    List<ExpressionVariable> variables,
  ) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/$projectId/$endpoint/evaluate',
    );
    try {
      final result = await apiClient.dio.postUri(
        uri,
        data: {
          'expression': expression,
          'variables': {
            for (final variable in variables)
              variable.name: variable.testValue ?? '',
          },
          'types': {
            for (final variable in variables) variable.name: variable.type.name,
          },
        },
      );
      return ExpressionResult.fromJson(result.data as Map<String, dynamic>);
    } on DioException catch (error) {
      if (error.response?.statusCode == 400) {
        throw ProblemDetail.fromDioException(error);
      }
      rethrow;
    }
  }

  /// Checks [expression] against the declared [variables] (their names) in the
  /// project [projectId], without evaluating it. The request goes to
  /// `project/{projectId}/expression/validate`. The backend answers every
  /// formula, valid or not, so only a transport failure throws.
  Future<ExpressionValidation> validate(
    String projectId,
    String expression,
    List<String> variables,
  ) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/$projectId/$endpoint/validate',
    );
    final result = await apiClient.dio.postUri<Map<String, dynamic>>(
      uri,
      data: {'expression': expression, 'variables': variables},
    );
    return ExpressionValidation.fromJson(result.data!);
  }
}
