import 'package:freezed_annotation/freezed_annotation.dart';

part 'release_model.g.dart';

part 'release_model.freezed.dart';

@freezed
abstract class ReleaseModel with _$ReleaseModel {

  const ReleaseModel._();

  const factory ReleaseModel({
    required String version,
    required DateTime publishedAt,
    String? url,
  }) = _ReleaseModel;

  factory ReleaseModel.fromJson(Map<String, dynamic> json) =>
      _$ReleaseModelFromJson(json);
}
