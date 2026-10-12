import 'package:stelaris/api/base_api.dart';
import 'package:stelaris_models/stelaris_models.dart';

/// Client API for interacting with project-related endpoints.
///
/// Extends [BaseApi] to provide standard CRUD operations for [Project] instances.
class ProjectClientApi extends BaseApi<Project> {
  /// Creates an instance of [ProjectClientApi].
  ///
  /// Requires an [apiClient] for making HTTP requests.
  /// The base endpoint for projects is set to 'project'.
  ProjectClientApi({required super.apiClient})
      : super(
          endpoint: 'project',
          fromJson: Project.fromJson,
          toJson: (p0) => p0.toJson(),
        );
}
