import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/data_model.dart';

part 'plugin_model.freezed.dart';
part 'plugin_model.g.dart';

@freezed
class PluginModel extends DataModel with _$PluginModel {

  const factory PluginModel({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'versionsString') String? versionsString,
    @JsonKey(name: 'ref') String? ref,
    @JsonKey(name: 'description') String? description
}) = _PluginModel;


  factory PluginModel.fromJson(Map<String, dynamic> json) =>
      _$PluginModelFromJson(json);
}

