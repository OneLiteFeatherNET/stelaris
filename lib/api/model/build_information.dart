import 'package:freezed_annotation/freezed_annotation.dart';

part 'build_information.freezed.dart';

part 'build_information.g.dart';

@freezed
class BuildInformation with _$BuildInformation {
  const factory BuildInformation({Map<String, String>? data}) =
      _BuildInformation;

  factory BuildInformation.fromJson(Map<String, dynamic> json) =>
      _$BuildInformationFromJson(json);
}
