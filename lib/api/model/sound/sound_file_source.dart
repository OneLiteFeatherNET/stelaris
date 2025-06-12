import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/data_model.dart';

part 'sound_file_source.freezed.dart';
part 'sound_file_source.g.dart';

@freezed
abstract class SoundFileSource with _$SoundFileSource, DataModel {

  const SoundFileSource._();

  const factory SoundFileSource({
    required String name,
    String? id,
    @Default(1.0) double volume,
    @Default(1.0) double pitch,
    int? weight,
    @Default(16) int attenuationDistance,
    @Default(false) bool preload,
    @Default('file') String type
}) = _SoundFileSource;


  factory SoundFileSource.fromJson(Map<String, dynamic> json) =>
      _$SoundFileSourceFromJson(json);
}
