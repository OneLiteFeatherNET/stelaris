import 'package:dio/dio.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/model/expression_function_model.dart';
import 'package:stelaris/api/model/expression_model.dart';
import 'package:stelaris/api/model/problem_detail.dart';

/// Client API for the project's functions: the CRUD endpoints every model has,
/// plus `evaluate`, which calls a function with test values, and `interface`,
/// which generates the Java source of the interface functions.
class ExpressionFunctionClientApi extends BaseApi<ExpressionFunctionModel> {
  /// Creates an instance of [ExpressionFunctionClientApi].
  ///
  /// The base endpoint for functions is set to 'expression-function'.
  ExpressionFunctionClientApi({required super.apiClient})
    : super(
        endpoint: 'expression-function',
        fromJson: ExpressionFunctionModel.fromJson,
        toJson: (model) => model.toJson(),
      );

  /// Calls [function] in the project [projectId] with the test values of its
  /// parameters, and returns what it came to. The function may be unsaved.
  ///
  /// The request goes to `project/{projectId}/expression-function/evaluate`
  /// with the function and its arguments, each parameter's test value by name.
  /// A parameter without a test value is sent as an empty string.
  ///
  /// A rejected function or argument (HTTP 400) throws a [ProblemDetail] whose
  /// `errors` name the field that failed. Any other failure is rethrown as it
  /// came.
  Future<ExpressionResult> evaluate(
    String projectId,
    ExpressionFunctionModel function,
  ) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/$projectId/$endpoint/evaluate',
    );
    try {
      final result = await apiClient.dio.postUri(
        uri,
        data: {
          'function': function.toJson(),
          'arguments': {
            for (final parameter in function.parameters)
              parameter.name: parameter.testValue ?? '',
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

  /// Loads the Java interface generated from the project's interface
  /// functions. The request goes to `project/{projectId}/expression-function/interface`.
  Future<ExpressionFunctionInterface> interface(String projectId) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/project/$projectId/$endpoint/interface',
    );
    final result = await apiClient.dio.getUri<Map<String, dynamic>>(uri);
    return ExpressionFunctionInterface.fromJson(result.data!);
  }
}
