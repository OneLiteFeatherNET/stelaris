import 'package:stelaris_ui/api/api_client.dart';
import 'package:stelaris_ui/api/service/block_api.dart';
import 'package:stelaris_ui/api/service/font_api.dart';
import 'package:stelaris_ui/api/service/item_api.dart';
import 'package:stelaris_ui/api/service/notification_api.dart';
import 'package:stelaris_ui/api/service/plugin_api.dart';

class ApiService {

  static final ApiService _apiService = ApiService._internal();

  factory ApiService() => _apiService;

  ApiService._internal();

  late final ApiClient _apiClient = _createApiClient();

  late final ApiClient _generatorClient = _createGeneratorClient();

  late final ItemApi itemApi = ItemApi(_apiClient);

  late final NotificationAPI notificationAPI = NotificationAPI(_apiClient);

  late final FontAPI fontAPI = FontAPI(_apiClient);

  late final BlockAPI blockAPI = BlockAPI(_apiClient);

  late final PluginAPI pluginAPI = PluginAPI(_apiClient);

  ApiClient _createApiClient() {
    return ApiClient("http://localhost:8080");
  }

  ApiClient _createGeneratorClient() {
    return ApiClient("");
  }
}