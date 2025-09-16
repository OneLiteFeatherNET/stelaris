import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/paginated_result.dart';

/// JSON converter for PaginatedResult<AttributeModel> so AppState can
/// persist and restore this field via Freezed's generated toJson/fromJson.
class AttributePaginatedResultConverter extends JsonConverter<
    PaginatedResult<AttributeModel>, Map<String, dynamic>> {
  const AttributePaginatedResultConverter();

  @override
  PaginatedResult<AttributeModel> fromJson(Map<String, dynamic> json) {
    return PaginatedResult<AttributeModel>.fromJson(
      json,
      (map) => AttributeModel.fromJson(map),
    );
  }

  @override
  Map<String, dynamic> toJson(PaginatedResult<AttributeModel> object) {
    return object.toJson((attr) => attr.toJson());
  }
}
