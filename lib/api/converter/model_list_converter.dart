import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/data_model.dart';

class ModelListConverter<T extends DataModel> implements JsonConverter<List<T>, List<dynamic>> {

  final T Function(dynamic) fromJsonConverter;

  const ModelListConverter(this.fromJsonConverter);

  @override
  List<T> fromJson(List<dynamic> json) {
    return json.map((e) => fromJsonConverter(e)).toList();
  }
  @override
  List<dynamic> toJson(List<T> object) {
    throw UnimplementedError();
  }
}
