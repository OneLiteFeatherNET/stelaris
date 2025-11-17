import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/model/item/item_lore_dto.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/paginated_result.dart';

class ItemAPI extends BaseApi<ItemModel> {
  ItemAPI({required super.apiClient})
    : super(
        endpoint: 'item',
        fromJson: (p0) => ItemModel.fromJson(p0),
        toJson: (model) => model.toJson(),
      );

  /// Get all enchantments for an item
  /// [id] the id of the item
  /// [page] the page number
  /// [size] the number of items per page
  /// Returns a [PaginatedResult] containing a [List] of [ItemEnchantmentDto]
  Future<PaginatedResult<ItemEnchantmentDto>> getEnchantments(
    String id, {
    int page = 1,
    int size = 10,
  }) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/$id/enchantments',
      queryParameters: {
        'page': (page - 1).toString(), // many backends use 0-based
        'size': size.toString(),
      },
    );
    final result = await apiClient.dio.getUri(uri);
    final data = result.data;

    return PaginatedResult.fromJson(data, (json) {
      final rawData = json as Map<String, dynamic>;
      return ItemEnchantmentDto.fromJson(rawData);
    });
  }

  /// Create a new enchantment for an item
  /// [id] the id of the item
  /// [dto] the [ItemEnchantmentDto]
  /// Returns a [ItemEnchantmentDto] containing the created enchantment
  Future<ItemEnchantmentDto> addEnchantment(
    String id,
    ItemEnchantmentDto dto,
  ) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/$id/enchantment',
    );
    final result = await apiClient.dio.putUri(uri, data: dto.toJson());
    return ItemEnchantmentDto.fromJson(result.data!);
  }

  /// Updates a new enchantment for an item
  /// [id] the id of the item
  /// [dto] the [ItemEnchantmentDto]
  /// Returns a [ItemEnchantmentDto] containing the created enchantment
  Future<ItemEnchantmentDto> updateEnchantment(
    String id,
    ItemEnchantmentDto dto,
  ) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/$id/enchantments',
    );
    final result = await apiClient.dio.postUri(uri, data: dto.toJson());
    return ItemEnchantmentDto.fromJson(result.data!);
  }

  /// Delete an enchantment for an item
  /// [id] the id of the item
  /// [dto] the [ItemEnchantmentDto]
  /// Returns a [ItemEnchantmentDto] containing the deleted enchantment
  Future<ItemEnchantmentDto> deleteEnchantment(
    String id,
    ItemEnchantmentDto dto,
  ) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/$id/enchantments',
    );
    final result = await apiClient.dio.deleteUri(uri, data: dto.toJson());
    return ItemEnchantmentDto.fromJson(result.data!);
  }

  /// Get all lore lines for an item
  /// [id] the id of the item
  /// [page] the page number
  /// [size] the number of items per page
  /// Returns a [PaginatedResult] containing a [List] of [ItemLoreDto]
  Future<PaginatedResult<ItemLoreDto>> getLore(
    String id, {
    int page = 1,
    int size = 10,
  }) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/$id/lore',
      queryParameters: {
        'page': (page - 1).toString(), // many backends use 0-based
        'size': size.toString(),
      },
    );
    final result = await apiClient.dio.getUri(uri);
    final data = result.data;

    return PaginatedResult.fromJson(data, (json) {
      final rawData = json as Map<String, dynamic>;
      return ItemLoreDto.fromJson(rawData);
    });
  }

  /// Create a new lore for an item
  /// [id] the id of the item
  /// [dto] the [ItemLoreDto]
  /// Returns a [ItemLoreDto] containing the created lore
  Future<ItemLoreDto> addLore(
      String id,
      ItemLoreDto dto,
      ) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(
      path: '${baseUri.path}/$endpoint/$id/lore',
    );
    final result = await apiClient.dio.putUri(uri, data: dto.toJson());
    return ItemLoreDto.fromJson(result.data!);
  }

  /// Update a lore line for an item
  /// [id] the id of the item
  /// [dto] the [ItemLoreDto]
  /// Returns a [ItemLoreDto] containing the updated lore
  Future<ItemLoreDto> updateLore(String id, ItemLoreDto dto) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/$id/lore');
    final result = await apiClient.dio.postUri(uri, data: dto.toJson());
    return ItemLoreDto.fromJson(result.data!);
  }

  /// Delete an lore for an item
  /// [id] the id of the item
  /// [dto] the [ItemLoreDto]
  /// Returns a [ItemLoreDto] containing the deleted lore
  Future<ItemLoreDto> deleteLore(String id, ItemLoreDto dto) async {
    final baseUri = Uri.parse(apiClient.baseUrl);
    final uri = baseUri.replace(path: '${baseUri.path}/$endpoint/$id/lore/${dto.id}');
    final result = await apiClient.dio.deleteUri(uri);
    return ItemLoreDto.fromJson(result.data!);
  }
}
