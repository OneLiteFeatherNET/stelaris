import 'package:stelaris/api/api_client.dart';
import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/service/client/project_client_api.dart';
import 'package:stelaris/api/service/client/sound_client_api.dart';
import 'package:stelaris/api/client_api.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/service/font_api.dart';
import 'package:stelaris/api/service/generate_api.dart';
import 'package:stelaris/api/service/item_api.dart';
import 'package:stelaris/env/runtime_config.dart';

/// The [ApiService] class contains all web services which are used in the app to communicate with the backend.
class ApiService {
  static final ApiService _apiService = ApiService._internal();

  factory ApiService() => _apiService;

  ApiService._internal();

  late final ApiClient _apiClient = _createApiClient();

  late final ApiClient _generatorClient = _createGeneratorClient();

  late final GenerateApi generateApi = GenerateApi(_generatorClient);

  late final ItemAPI itemApi = ItemAPI(apiClient: _apiClient);

  late final ClientAPI<NotificationModel> notificationApi = BaseApi(
    apiClient: _apiClient,
    endpoint: 'notification',
    fromJson: (p0) => NotificationModel.fromJson(p0),
    toJson: (model) => model.toJson(),
  );

  late final FontAPI fontApi = FontAPI(apiClient: _apiClient);

  late final ClientAPI<AttributeModel> attributeApi = BaseApi(
    apiClient: _apiClient,
    endpoint: 'attribute',
    fromJson: (p0) => AttributeModel.fromJson(p0),
    toJson: (model) => model.toJson(),
  );

  late final ClientAPI<SoundEventModel> soundApi = SoundClientApi(
    apiClient: _apiClient,
  );

  late final ProjectClientApi projectApi = ProjectClientApi(
    apiClient: _apiClient,
  );

  /// Creates an instance of [ApiClient] with the backend URL.
  ///
  /// Read from [RuntimeConfig] rather than from the compiled-in constants, so
  /// the client points at whatever the deployment configured. The clients are
  /// `late final`, so this runs on first use - long after `main()` has loaded
  /// the configuration.
  ApiClient _createApiClient() => ApiClient(RuntimeConfig.current.backendUrl);

  /// Creates an instance of [ApiClient] with the generator URL.
  ApiClient _createGeneratorClient() =>
      ApiClient(RuntimeConfig.current.generatorUrl);
}
