

import 'package:stelaris_ui/api/ApiClient.dart';
import 'package:stelaris_ui/api/service/item_api.dart';

class ApiService {

  static final ApiService _apiService = ApiService._internal();

  factory ApiService() => _apiService;

  ApiService._internal();

  late final ApiClient _apiClient = _createApiClient();

  late final ItemApi itemApi = ItemApi(_apiClient);

  ApiClient _createApiClient() {
    return ApiClient("");
  }
}