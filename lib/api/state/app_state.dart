import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris/api/model/attribute_model.dart';
import 'package:stelaris/api/model/font_model.dart';
import 'package:stelaris/api/model/item_model.dart';
import 'package:stelaris/api/model/notification_model.dart';

part 'app_state.g.dart';
part 'app_state.freezed.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default([]) List<ItemModel> items,
    @Default([]) List<NotificationModel> notifications,
    @Default([]) List<FontModel> fonts,
    @Default(<AttributeModel>[]) List<AttributeModel> attributes,
    @Default(true) bool openNavigation,
    @Default(true) bool nightMode,
    @JsonKey(includeToJson: false) ItemModel? selectedItem,
    @JsonKey(includeToJson: false) NotificationModel? selectedNotification,
    @JsonKey(includeToJson: false) FontModel? selectedFont,
    @JsonKey(includeToJson: false) AttributeModel? selectedAttribute,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}
