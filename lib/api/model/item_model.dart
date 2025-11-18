import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/data_model.dart';
import 'package:stelaris/api/model/item/item_enchantment_dto.dart';
import 'package:stelaris/api/model/item/item_flag_dto.dart';
import 'package:stelaris/api/model/item/item_lore_dto.dart';
import 'package:stelaris/api/paginated_result.dart';
import 'package:stelaris/feature/item/item_group.dart';

part 'item_model.g.dart';
part 'item_model.freezed.dart';

ItemModel itemModelFromJson(Object? json) =>
    ItemModel.fromJson(json as Map<String, dynamic>);

Map<String, dynamic> itemModelToJson(ItemModel item) => item.toJson();

@freezed
abstract class ItemModel with _$ItemModel, DataModel {

  // Define the specific const default directly within the class that uses it.
  // This is well-encapsulated.
  static const PaginatedResult<ItemEnchantmentDto> _defaultEnchantments = PaginatedResult(
    items: <ItemEnchantmentDto>[],
    totalItems: 0,
    totalPages: 0,
    currentPage: 1,
    pageSize: 0,
  );

  // Define the specific const default directly within the class that uses it.
  // This is well-encapsulated.
  static const PaginatedResult<ItemLoreDto> _defaultLore = PaginatedResult(
    items: <ItemLoreDto>[],
    totalItems: 0,
    totalPages: 0,
    currentPage: 1,
    pageSize: 0,
  );

  // Define the specific const default directly within the class that uses it.
  // This is well-encapsulated.
  static const PaginatedResult<ItemFlagDto> _defaultFlags = PaginatedResult(
    items: <ItemFlagDto>[],
    totalItems: 0,
    totalPages: 0,
    currentPage: 0,
    pageSize: 0,
  );

  const ItemModel._(); // Add this private constructor

  const factory ItemModel({
    required String uiName,
    String? id,
    String? variableName,
    String? comment,
    String? displayName,
    @Default(EnchantmentGroup.meta) EnchantmentGroup group,
    String? material,
    int? customModelData,
    @Default(1) int? amount,
    @Default(ItemModel._defaultEnchantments)
    PaginatedResult<ItemEnchantmentDto> enchantments,
    @Default(ItemModel._defaultLore)
    PaginatedResult<ItemLoreDto> lore,
    @Default(ItemModel._defaultFlags)
    PaginatedResult<ItemFlagDto> flags,
    @Default(false) @JsonKey(includeToJson: false) bool isLoadingMoreEnchantments,
    @Default(false) @JsonKey(includeToJson: false) bool isLoadingMoreLoreLines
  }) = _ItemModel;

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);
}