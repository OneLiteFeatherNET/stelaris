import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/service/attributes_api.dart';
import 'package:stelaris/api/service/font_api.dart';
import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris/api/service/item_api.dart';
import 'package:stelaris/api/service/notification_api.dart';
import 'package:stelaris/env/environment.dart';

/// The [ApiService] class contains all web services which are used in the app to communicate with the backend.
class ApiService {
  static final ApiService _apiService = ApiService._internal();

  factory ApiService() => _apiService;

  ApiService._internal();

  late final ApiClient _apiClient = _createApiClient();

  late final ApiClient _generatorClient = _createGeneratorClient();

  late final GenerateApi generateApi = GenerateApi(_generatorClient);

  late final ItemApi itemApi = ItemApi(_apiClient);

  late final NotificationAPI notificationAPI = NotificationAPI(_apiClient);

  late final FontAPI fontAPI = FontAPI(_apiClient);

  late final AttributesAPI attributesAPI = AttributesAPI(_apiClient);

  /// Creates an instance of [ApiClient] with the backend URL.
  ApiClient _createApiClient() => ApiClient(Environment.backendURl);

  /// Creates an instance of [ApiClient] with the generator URL.
  ApiClient _createGeneratorClient() => ApiClient(Environment.generatorUrl);
}
