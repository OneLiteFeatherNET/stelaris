import 'package:freezed_annotation/freezed_annotation.dart';

part 'version.freezed.dart';
part 'version.g.dart';

@freezed
class VersionModel with _$VersionModel {

  const factory VersionModel({
    @JsonKey(name: "version")@Default('1.0.0') String version
  }) = _VersionModel;


  factory VersionModel.fromJson(Map<String, dynamic> json) =>
      _$VersionModelFromJson(json);
}