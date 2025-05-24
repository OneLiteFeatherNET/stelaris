// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get delete_dialog_first_line => 'Do you really want to delete ';

  @override
  String get delete_dialog_entry => ' entry';

  @override
  String get button_add => 'Add';

  @override
  String get button_save => 'Save';

  @override
  String get button_download => 'Download';

  @override
  String get button_generate => 'Generate';

  @override
  String get button_trigger_go => 'Go!';

  @override
  String get button_finish => 'Finish';

  @override
  String get button_continue => 'Continue';

  @override
  String get button_ok => 'Ok';

  @override
  String get button_back => 'Back';

  @override
  String get button_yes => 'Yes';

  @override
  String get button_cancel => 'Cancel';

  @override
  String get button_add_new_line => 'Add new line';

  @override
  String get text_branch => 'Please select a branch';

  @override
  String get text_trigger_title => 'Trigger a new build';

  @override
  String get text_version_new => 'Add new version';

  @override
  String get text_version_type => 'Version type';

  @override
  String get text_wiki =>
      'When you need help, click on the copy button the get the wiki link';

  @override
  String get setup_new_model => 'Create new model';

  @override
  String get setup_invalid_name =>
      'The name must start with a character not with a number';

  @override
  String get dialog_enchantment_title => 'Add a enchantment';

  @override
  String get dialog_enchantment_enchantment => 'Enchantment';

  @override
  String get dialog_delete_confirm => 'Confirm deletion';

  @override
  String get dialog_abort_flags_title => 'Test';

  @override
  String get dialog_abort_flags =>
      'Unable to set flags because all available flags are set';

  @override
  String get dialog_abort_enchantment_title => 'Test';

  @override
  String get dialog_level_title => 'Edit level';

  @override
  String get dialog_lore_edit_title => 'Edit lore';

  @override
  String get dialog_level_validation => 'The level can\'t be empty';

  @override
  String get dialog_level_delete_first_line => 'Do you really want to delete ';

  @override
  String get dialog_abort_enchantments =>
      'Unable to set enchantment because all are set';

  @override
  String get dialog_abort_chars_add => 'Unable to add char';

  @override
  String get dialog_abort_chars_text => 'There is already an entry called ';

  @override
  String get dialog_char_title => 'Add char';

  @override
  String get dialog_group_change => 'Change group?';

  @override
  String get dialog_group_change_text =>
      'The model contains enchantments which are not in the new selected group.\nAll enchantments which are not in the group will be deleted.\n\nAre you sure you want to change the group?';

  @override
  String get input_validation_material =>
      'The material starts not with minecraft:';

  @override
  String get error_generation_failure => 'Generation failure in the backend';

  @override
  String get error_generation_submit => 'Generation submitted to backend';

  @override
  String get error_not_unicode_start =>
      'The string does not start\'s with a \\u';

  @override
  String get error_not_unicode => 'The string is to long for a unicode';

  @override
  String get error_card_empty => 'The value can\'t be empty';

  @override
  String get tooltip_delete => 'Delete';

  @override
  String get tooltip_material => 'Change the material';

  @override
  String get tooltip_name => 'Change the name for the variable';

  @override
  String get tooltip_model_data => 'Change the model data';

  @override
  String get tooltip_description => 'Change description';

  @override
  String get tooltip_displayname => 'Change the Displayname';

  @override
  String get tooltip_title => 'Change title';

  @override
  String get tooltip_flag => 'Change the flags';

  @override
  String get tooltip_amount => 'Change amount';

  @override
  String get tooltip_ascent => 'Change ascent';

  @override
  String get tooltip_height => 'Change height';

  @override
  String get enum_dialog_flags => 'Add a flag';

  @override
  String get card_name => 'Variable Name';

  @override
  String get card_description => 'Description';

  @override
  String get card_amount => 'Amount';

  @override
  String get card_material => 'Material';

  @override
  String get card_model_data => 'ModelData';

  @override
  String get card_flags => 'Flags';

  @override
  String get card_enchantments => 'Enchantments';

  @override
  String get card_lore => 'Lore';

  @override
  String get card_display_name => 'DisplayName';

  @override
  String get card_title => 'Title';

  @override
  String get card_frame_type => 'FrameType';

  @override
  String get card_type => 'Type';

  @override
  String get card_ascent => 'Ascent';

  @override
  String get card_height => 'Height';

  @override
  String get card_chars => 'Chars';

  @override
  String get card_group => 'Group';

  @override
  String get card_amount_to_high => 'The maximum amount is 64';

  @override
  String get label_level => 'Level';

  @override
  String get settings_display_title => 'Display settings';

  @override
  String get settings_display_header => 'Dark Mode';

  @override
  String get settings_display_body => 'Update your preferred theme';

  @override
  String get settings_theme_colors => 'Theme Colors';

  @override
  String get settings_primary_color => 'Primary Color';

  @override
  String get settings_primary_color_desc =>
      'Choose the primary color for the app theme';

  @override
  String get settings_accent_color => 'Accent Color';

  @override
  String get settings_accent_color_desc =>
      'Choose the accent color for the app theme';

  @override
  String get settings_accessibility_title => 'Accessibility';

  @override
  String get settings_accessibility_header => 'Need some help?';

  @override
  String get settings_accessibility_body =>
      'For assistance, feel free to explore our wiki';

  @override
  String get settings_accessibility_button => 'Wiki';

  @override
  String get settings_misc_title => 'Misc';

  @override
  String get settings_misc_bug_header => 'Found a bug?';

  @override
  String get settings_misc_bug_body =>
      'When you encounter a bug, please report it!';

  @override
  String get settings_misc_bug_button => 'Report';

  @override
  String get settings_misc_suggestion_header => 'Any Suggestion?';

  @override
  String get settings_misc_suggestion_body =>
      'Want to suggest a feature, create a ticket!';

  @override
  String get settings_misc_suggestion_button => 'Suggest';
}
