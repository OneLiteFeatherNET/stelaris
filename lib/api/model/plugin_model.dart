import 'package:freezed_annotation/freezed_annotation.dart';

part 'plugin_model.freezed.dart';
part 'plugin_model.g.dart';

@freezed
class Plugin with _$PluginModel {

  const factory Plugin({
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'version') String? version,
    @JsonKey(name: 'ref') String? ref
}) = _PluginModel;


  factory Plugin.fromJson(Map<String, dynamic> json) =>
      _$PluginModelFromJson(json);
}

