import 'package:material_ui/material_ui.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/api/model/problem_detail.dart';
import 'package:stelaris/api/model/theme/theme_settings.dart';
import 'package:stelaris/api/state/expression_validation_state.dart';
import 'package:stelaris/api/state/model_search_state.dart';
import 'package:stelaris/api/util/navigation.dart';
import 'package:stelaris/feature/command_palette/entity_search_state.dart';
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
      PaginatedResult<AdvancementModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<AdvancementModel> advancements,
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
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(
      PaginatedResult<ExpressionModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<ExpressionModel> expressions,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(
      PaginatedResult<ExpressionFunctionModel>(
        items: [],
        totalItems: 0,
        totalPages: 0,
        currentPage: 1,
        pageSize: 0,
      ),
    )
    PaginatedResult<ExpressionFunctionModel> expressionFunctions,

    // ── Transiente Loading-Flags ──
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingAttributesMore,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreItems,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreAdvancements,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreFonts,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreSoundEvents,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreExpressions,
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(false)
    bool isLoadingMoreExpressionFunctions,
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
    // The data components of the selected item, loaded by its components tab.
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default([])
    List<ItemComponentDto> selectedItemComponents,
    @JsonKey(includeToJson: false, includeFromJson: false)
    AdvancementModel? selectedAdvancement,
    @JsonKey(includeToJson: false, includeFromJson: false)
    FontModel? selectedFont,
    @JsonKey(includeToJson: false, includeFromJson: false)
    AttributeModel? selectedAttribute,
    @JsonKey(includeToJson: false, includeFromJson: false)
    SoundEventModel? selectedSoundEvent,
    @JsonKey(includeToJson: false, includeFromJson: false)
    ExpressionModel? selectedExpression,
    @JsonKey(includeToJson: false, includeFromJson: false)
    ExpressionFunctionModel? selectedExpressionFunction,
    // The rejection of the selected function's last save, with the field
    // violations to show at the fields. Null when the save was accepted.
    @JsonKey(includeToJson: false, includeFromJson: false)
    ProblemDetail? expressionFunctionProblem,
    // The EvalEx catalog for the formula editor, with the functions of the
    // project it was loaded for. Null until it has loaded or when it failed.
    @JsonKey(includeToJson: false, includeFromJson: false)
    ExpressionCatalog? expressionCatalog,
    @JsonKey(includeToJson: false, includeFromJson: false)
    String? expressionCatalogProjectId,
    // The backend's check of the selected formula while it is typed. Null
    // until a check has answered, and when the last one failed.
    @JsonKey(includeToJson: false, includeFromJson: false)
    ExpressionValidationState? expressionValidation,
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

    /// The command palette's entity search: the question, the source's hits
    /// and where its answer stands. Transient, like the caches above.
    @JsonKey(includeToJson: false, includeFromJson: false)
    @Default(EntitySearchState())
    EntitySearchState entitySearch,

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
