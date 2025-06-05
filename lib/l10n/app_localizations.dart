import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @delete_dialog_first_line.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete '**
  String get delete_dialog_first_line;

  /// No description provided for @delete_dialog_entry.
  ///
  /// In en, this message translates to:
  /// **' entry'**
  String get delete_dialog_entry;

  /// No description provided for @button_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get button_add;

  /// No description provided for @button_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get button_save;

  /// No description provided for @button_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get button_download;

  /// No description provided for @button_generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get button_generate;

  /// No description provided for @button_trigger_go.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get button_trigger_go;

  /// No description provided for @button_finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get button_finish;

  /// No description provided for @button_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get button_continue;

  /// No description provided for @button_ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get button_ok;

  /// No description provided for @button_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get button_back;

  /// No description provided for @button_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get button_yes;

  /// No description provided for @button_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get button_cancel;

  /// No description provided for @button_add_new_line.
  ///
  /// In en, this message translates to:
  /// **'Add new line'**
  String get button_add_new_line;

  /// No description provided for @text_branch.
  ///
  /// In en, this message translates to:
  /// **'Please select a branch'**
  String get text_branch;

  /// No description provided for @text_trigger_title.
  ///
  /// In en, this message translates to:
  /// **'Trigger a new build'**
  String get text_trigger_title;

  /// No description provided for @text_version_new.
  ///
  /// In en, this message translates to:
  /// **'Add new version'**
  String get text_version_new;

  /// No description provided for @text_version_type.
  ///
  /// In en, this message translates to:
  /// **'Version type'**
  String get text_version_type;

  /// No description provided for @text_wiki.
  ///
  /// In en, this message translates to:
  /// **'When you need help, click on the copy button the get the wiki link'**
  String get text_wiki;

  /// No description provided for @setup_new_model.
  ///
  /// In en, this message translates to:
  /// **'Create new model'**
  String get setup_new_model;

  /// No description provided for @setup_invalid_name.
  ///
  /// In en, this message translates to:
  /// **'The name must start with a character not with a number'**
  String get setup_invalid_name;

  /// No description provided for @dialog_enchantment_title.
  ///
  /// In en, this message translates to:
  /// **'Add a enchantment'**
  String get dialog_enchantment_title;

  /// No description provided for @dialog_enchantment_enchantment.
  ///
  /// In en, this message translates to:
  /// **'Enchantment'**
  String get dialog_enchantment_enchantment;

  /// No description provided for @dialog_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get dialog_delete_confirm;

  /// No description provided for @dialog_abort_flags_title.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get dialog_abort_flags_title;

  /// No description provided for @dialog_abort_flags.
  ///
  /// In en, this message translates to:
  /// **'Unable to set flags because all available flags are set'**
  String get dialog_abort_flags;

  /// No description provided for @dialog_abort_enchantment_title.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get dialog_abort_enchantment_title;

  /// No description provided for @dialog_level_title.
  ///
  /// In en, this message translates to:
  /// **'Edit level'**
  String get dialog_level_title;

  /// No description provided for @dialog_lore_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit lore'**
  String get dialog_lore_edit_title;

  /// No description provided for @dialog_level_validation.
  ///
  /// In en, this message translates to:
  /// **'The level can\'t be empty'**
  String get dialog_level_validation;

  /// No description provided for @dialog_level_delete_first_line.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete '**
  String get dialog_level_delete_first_line;

  /// No description provided for @dialog_abort_enchantments.
  ///
  /// In en, this message translates to:
  /// **'Unable to set enchantment because all are set'**
  String get dialog_abort_enchantments;

  /// No description provided for @dialog_abort_chars_add.
  ///
  /// In en, this message translates to:
  /// **'Unable to add char'**
  String get dialog_abort_chars_add;

  /// No description provided for @dialog_abort_chars_text.
  ///
  /// In en, this message translates to:
  /// **'There is already an entry called '**
  String get dialog_abort_chars_text;

  /// No description provided for @dialog_char_title.
  ///
  /// In en, this message translates to:
  /// **'Add char'**
  String get dialog_char_title;

  /// No description provided for @dialog_group_change.
  ///
  /// In en, this message translates to:
  /// **'Change group?'**
  String get dialog_group_change;

  /// No description provided for @dialog_group_change_text.
  ///
  /// In en, this message translates to:
  /// **'The model contains enchantments which are not in the new selected group.\nAll enchantments which are not in the group will be deleted.\n\nAre you sure you want to change the group?'**
  String get dialog_group_change_text;

  /// No description provided for @input_validation_material.
  ///
  /// In en, this message translates to:
  /// **'The material starts not with minecraft:'**
  String get input_validation_material;

  /// No description provided for @error_generation_failure.
  ///
  /// In en, this message translates to:
  /// **'Generation failure in the backend'**
  String get error_generation_failure;

  /// No description provided for @error_generation_submit.
  ///
  /// In en, this message translates to:
  /// **'Generation submitted to backend'**
  String get error_generation_submit;

  /// No description provided for @error_not_unicode_start.
  ///
  /// In en, this message translates to:
  /// **'The string does not start\'s with a \\u'**
  String get error_not_unicode_start;

  /// No description provided for @error_not_unicode.
  ///
  /// In en, this message translates to:
  /// **'The string is to long for a unicode'**
  String get error_not_unicode;

  /// No description provided for @error_card_empty.
  ///
  /// In en, this message translates to:
  /// **'The value can\'t be empty'**
  String get error_card_empty;

  /// No description provided for @tooltip_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tooltip_delete;

  /// No description provided for @tooltip_material.
  ///
  /// In en, this message translates to:
  /// **'Change the material'**
  String get tooltip_material;

  /// No description provided for @tooltip_name.
  ///
  /// In en, this message translates to:
  /// **'Change the name for the variable'**
  String get tooltip_name;

  /// No description provided for @tooltip_model_data.
  ///
  /// In en, this message translates to:
  /// **'Change the model data'**
  String get tooltip_model_data;

  /// No description provided for @tooltip_description.
  ///
  /// In en, this message translates to:
  /// **'Change description'**
  String get tooltip_description;

  /// No description provided for @tooltip_displayname.
  ///
  /// In en, this message translates to:
  /// **'Change the Displayname'**
  String get tooltip_displayname;

  /// No description provided for @tooltip_title.
  ///
  /// In en, this message translates to:
  /// **'Change title'**
  String get tooltip_title;

  /// No description provided for @tooltip_flag.
  ///
  /// In en, this message translates to:
  /// **'Change the flags'**
  String get tooltip_flag;

  /// No description provided for @tooltip_amount.
  ///
  /// In en, this message translates to:
  /// **'Change amount'**
  String get tooltip_amount;

  /// No description provided for @tooltip_ascent.
  ///
  /// In en, this message translates to:
  /// **'Change ascent'**
  String get tooltip_ascent;

  /// No description provided for @tooltip_height.
  ///
  /// In en, this message translates to:
  /// **'Change height'**
  String get tooltip_height;

  /// No description provided for @enum_dialog_flags.
  ///
  /// In en, this message translates to:
  /// **'Add a flag'**
  String get enum_dialog_flags;

  /// No description provided for @card_name.
  ///
  /// In en, this message translates to:
  /// **'Variable Name'**
  String get card_name;

  /// No description provided for @card_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get card_description;

  /// No description provided for @card_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get card_amount;

  /// No description provided for @card_material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get card_material;

  /// No description provided for @card_model_data.
  ///
  /// In en, this message translates to:
  /// **'ModelData'**
  String get card_model_data;

  /// No description provided for @card_flags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get card_flags;

  /// No description provided for @card_enchantments.
  ///
  /// In en, this message translates to:
  /// **'Enchantments'**
  String get card_enchantments;

  /// No description provided for @card_lore.
  ///
  /// In en, this message translates to:
  /// **'Lore'**
  String get card_lore;

  /// No description provided for @card_display_name.
  ///
  /// In en, this message translates to:
  /// **'DisplayName'**
  String get card_display_name;

  /// No description provided for @card_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get card_title;

  /// No description provided for @card_frame_type.
  ///
  /// In en, this message translates to:
  /// **'FrameType'**
  String get card_frame_type;

  /// No description provided for @card_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get card_type;

  /// No description provided for @card_ascent.
  ///
  /// In en, this message translates to:
  /// **'Ascent'**
  String get card_ascent;

  /// No description provided for @card_height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get card_height;

  /// No description provided for @card_chars.
  ///
  /// In en, this message translates to:
  /// **'Chars'**
  String get card_chars;

  /// No description provided for @card_group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get card_group;

  /// No description provided for @card_amount_to_high.
  ///
  /// In en, this message translates to:
  /// **'The maximum amount is 64'**
  String get card_amount_to_high;

  /// No description provided for @label_level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get label_level;

  /// No description provided for @settings_display_title.
  ///
  /// In en, this message translates to:
  /// **'Display settings'**
  String get settings_display_title;

  /// No description provided for @settings_display_header.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settings_display_header;

  /// No description provided for @settings_display_body.
  ///
  /// In en, this message translates to:
  /// **'Update your preferred theme'**
  String get settings_display_body;

  /// No description provided for @settings_theme_colors.
  ///
  /// In en, this message translates to:
  /// **'Theme Colors'**
  String get settings_theme_colors;

  /// No description provided for @settings_primary_color.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get settings_primary_color;

  /// No description provided for @settings_primary_color_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose the primary color for the app theme'**
  String get settings_primary_color_desc;

  /// No description provided for @settings_accent_color.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get settings_accent_color;

  /// No description provided for @settings_accent_color_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose the accent color for the app theme'**
  String get settings_accent_color_desc;

  /// No description provided for @settings_accessibility_title.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settings_accessibility_title;

  /// No description provided for @settings_accessibility_header.
  ///
  /// In en, this message translates to:
  /// **'Need some help?'**
  String get settings_accessibility_header;

  /// No description provided for @settings_accessibility_body.
  ///
  /// In en, this message translates to:
  /// **'For assistance, feel free to explore our wiki'**
  String get settings_accessibility_body;

  /// No description provided for @settings_accessibility_button.
  ///
  /// In en, this message translates to:
  /// **'Wiki'**
  String get settings_accessibility_button;

  /// No description provided for @settings_misc_title.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get settings_misc_title;

  /// No description provided for @settings_misc_bug_header.
  ///
  /// In en, this message translates to:
  /// **'Found a bug?'**
  String get settings_misc_bug_header;

  /// No description provided for @settings_misc_bug_body.
  ///
  /// In en, this message translates to:
  /// **'When you encounter a bug, please report it!'**
  String get settings_misc_bug_body;

  /// No description provided for @settings_misc_bug_button.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get settings_misc_bug_button;

  /// No description provided for @settings_misc_suggestion_header.
  ///
  /// In en, this message translates to:
  /// **'Any Suggestion?'**
  String get settings_misc_suggestion_header;

  /// No description provided for @settings_misc_suggestion_body.
  ///
  /// In en, this message translates to:
  /// **'Want to suggest a feature, create a ticket!'**
  String get settings_misc_suggestion_body;

  /// No description provided for @settings_misc_suggestion_button.
  ///
  /// In en, this message translates to:
  /// **'Suggest'**
  String get settings_misc_suggestion_button;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
