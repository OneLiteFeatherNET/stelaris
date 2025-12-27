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
    @Default(false) bool prerelease,
    // The naming of this comes from the official api https://docs.github.com/en/rest/releases/releases. Search for target_commitish
    String? targetCommitish,
  }) = _ReleaseModel;

  factory ReleaseModel.fromJson(Map<String, dynamic> json) =>
      _$ReleaseModelFromJson(json);
}
