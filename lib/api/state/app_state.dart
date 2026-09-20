import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/auth/auth_state.dart';

part 'app_state.g.dart';

part 'app_state.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class AppState with _$AppState {
  const factory AppState({
    // ── API-Caches: werden beim Navigieren frisch vom Backend geladen ──
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(
      PaginatedResult<ItemModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<ItemModel> items,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(
      PaginatedResult<NotificationModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<NotificationModel> notifications,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(
      PaginatedResult<FontModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<FontModel> fonts,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(
      PaginatedResult<AttributeModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<AttributeModel> attributes,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(
      PaginatedResult<SoundEventModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<SoundEventModel> soundEvents,

    // ── Transiente Loading-Flags ──
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingAttributesMore,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreItems,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreNotifications,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreFonts,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreSoundEvents,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingRelease,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingBranches,

    // ── Persistierte Einstellungen ──
    @Default(true) bool openNavigation,
    @Default(
      ThemeSettings(
        isDarkMode: false,
        primaryColor: Colors.blue,
        accentColor: Colors.blueAccent,
        fontScale: 1,
        useSystemTheme: true,
      ),
    )
    ThemeSettings themeSettings,
    @Default([]) List<Project> projects,

    @JsonKey(includeToJson: false, includeFromJson: false)
    ItemModel? selectedItem,
    @JsonKey(includeToJson: false, includeFromJson: false)
    NotificationModel? selectedNotification,
    @JsonKey(includeToJson: false, includeFromJson: false)
    FontModel? selectedFont,
    @JsonKey(includeToJson: false, includeFromJson: false)
    AttributeModel? selectedAttribute,
    @JsonKey(includeToJson: false, includeFromJson: false)
    SoundEventModel? selectedSoundEvent,
    @JsonKey(includeToJson: false, includeFromJson: false)
    ReleaseModel? releaseModel,
    @JsonKey(includeToJson: false, includeFromJson: false)
    List<String>? branches,
    @JsonKey(includeToJson: false, includeFromJson: false)
    Project? selectedProject,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(ModelSearchState())
    ModelSearchState modelSearch,

    /// The section whose selected model has form edits that haven't been
    /// saved yet. Set only by the form update actions (UpdateItemAction etc.)
    /// — not derived by comparing the selection to a snapshot, since lore,
    /// enchantments, font chars and sound files are saved straight to the
    /// API and written into the selection as well.
    @JsonKey(includeToJson: false, includeFromJson: false)
    NavigationEntry? unsavedChanges,

    // ── Sitzung ──
    // Transient on purpose, and excluded from JSON like the caches above. Two
    // reasons, either of which would be enough: this state is derived from the
    // session store, so a persisted copy could claim someone is signed in after
    // their session is gone; and everything persisted here lands in
    // localStorage, which is the last place credentials or anything derived
    // from them belong. See [AuthState].
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(AuthState.disabled())
    AuthState auth,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}
