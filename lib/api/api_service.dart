import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris/env/environment.dart';
import 'package:vulpes_backend_client/vulpes_backend_client.dart';

/// The [ApiService] class contains all web services which are used in the app to communicate with the backend.
class ApiService {
  static final ApiService _apiService = ApiService._internal();

  factory ApiService() => _apiService;

  ApiService._internal();

  late final VulpesBackendClient _apiClient = _createApiClient();

  late final ApiClient _generatorClient = _createGeneratorClient();

  late final GenerateApi generateApi = GenerateApi(_generatorClient);

  late final ItemApi itemApi = _apiClient.getItemApi();

  late final NotificationApi notificationApi = _apiClient.getNotificationApi();

  late final FontApi fontApi = _apiClient.getFontApi();

  late final AttributeApi attributeApi = _apiClient.getAttributeApi();

  /// Creates an instance of [ApiClient] with the backend URL.
  VulpesBackendClient _createApiClient() => VulpesBackendClient(basePathOverride: Environment.backendURl);

  /// Creates an instance of [ApiClient] with the generator URL.
  ApiClient _createGeneratorClient() => ApiClient(Environment.generatorUrl);
}
