import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_ui/api/model/block_model.dart';
import 'package:stelaris_ui/api/model/font_model.dart';
import 'package:stelaris_ui/api/model/notification_model.dart';
import 'package:stelaris_ui/api/model/plugin_model.dart';

import '../model/item_model.dart';

part 'app_state.g.dart';

part 'app_state.freezed.dart';

@freezed
class AppState with _$AppState {
  // Missing Json anno
  const factory AppState({
    @Default([]) List<ItemModel> items,
    @Default([]) List<NotificationModel> notifications,
    @Default([]) List<FontModel> fonts,
    @Default([]) List<PluginModel> plugins,
    @Default([]) List<BlockModel> blocks,
    @Default(true) bool openNavigation,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}
