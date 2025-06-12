
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/data_model.dart';

part 'sound_event_model.freezed.dart';
part 'sound_event_model.g.dart';


@freezed
abstract class SoundEventModel with _$SoundEventModel, DataModel {

  const SoundEventModel._();

  const factory SoundEventModel({
    required String uiName,
    String? id,
    String? variableName,
    String? keyName,
    String? subTitle
  }) = _SoundEventModel;

  factory SoundEventModel.fromJson(Map<String, dynamic> json) =>
      _$SoundEventModelFromJson(json);
}