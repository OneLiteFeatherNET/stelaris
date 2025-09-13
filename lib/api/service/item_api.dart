import 'package:stelaris/api/base_api.dart';
import 'package:stelaris/api/model/item_model.dart';

class ItemAPI extends BaseApi<ItemModel> {

  ItemAPI({required super.apiClient})
      : super(
    endpoint: 'item',
    fromJson: (p0) => ItemModel.fromJson(p0),
    toJson: (model) => model.toJson(),
  );

}