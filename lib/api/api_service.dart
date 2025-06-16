import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/client_api.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/model/notification_model.dart';
import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris/env/environment.dart';

/// The [ApiService] class contains all web services which are used in the app to communicate with the backend.
class ApiService {
  static final ApiService _apiService = ApiService._internal();

  factory ApiService() => _apiService;

  ApiService._internal();

  late final ApiClient _apiClient = _createApiClient();

  late final ApiClient _generatorClient = _createGeneratorClient();

  late final GenerateApi generateApi = GenerateApi(_generatorClient);

  late final ClientAPI<ItemModel> itemApi = BaseApi(
    apiClient: _apiClient,
    endpoint: 'item',
    fromJson: (p0) => ItemModel.fromJson(p0),
    toJson: (model) => model.toJson(),
  );

  late final ClientAPI<NotificationModel> notificationApi = BaseApi(
    apiClient: _apiClient,
    endpoint: 'notification',
    fromJson: (p0) => NotificationModel.fromJson(p0),
    toJson: (model) => model.toJson(),
  );

  late final ClientAPI<FontModel> fontApi = BaseApi(
    apiClient: _apiClient,
    endpoint: 'font',
    fromJson: (p0) => FontModel.fromJson(p0),
    toJson: (model) => model.toJson(),
  );

  late final ClientAPI<AttributeModel> attributeApi = BaseApi(
    apiClient: _apiClient,
    endpoint: 'attribute',
    fromJson: (p0) => AttributeModel.fromJson(p0),
    toJson: (model) => model.toJson(),
  );

  /// Creates an instance of [ApiClient] with the backend URL.
  ApiClient _createApiClient() => ApiClient(Environment.backendURl);

  /// Creates an instance of [ApiClient] with the generator URL.
  ApiClient _createGeneratorClient() => ApiClient(Environment.generatorUrl);
}
