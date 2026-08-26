// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get button_add => 'Add';

  @override
  String get button_add_new_line => 'Add new line';

  @override
  String get button_save => 'Save';

  @override
  String get button_download => 'Download';

  @override
  String get button_generate => 'Generate';

  @override
  String get button_trigger_go => 'Go!';

  @override
  String get button_continue => 'Continue';

  @override
  String get button_finish => 'Finish';

  @override
  String get button_back => 'Back';

  @override
  String get button_ok => 'Ok';

  @override
  String get button_yes => 'Yes';

  @override
  String get button_cancel => 'Cancel';

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
  String get delete_dialog_first_line => 'Do you really want to delete ';

  @override
  String get delete_dialog_entry => ' entry';

  @override
  String get dialog_delete_confirm => 'Confirm deletion';

  @override
  String get dialog_attribute_create => 'Create attribute';

  @override
  String get dialog_item_create => 'Create new item';

  @override
  String get dialog_item_group_change_title => 'Group change';

  @override
  String get dialog_item_group_change_header =>
      'A change of the group will reset each selected enchantment';

  @override
  String get dialog_item_group_change_confirm => 'Do you want to proceed?';

  @override
  String get dialog_item_enchantment_title => 'Add a enchantment';

  @override
  String get dialog_item_enchantment => 'Enchantment';

  @override
  String get dialog_item_enchantment_level_edit => 'Update Level';

  @override
  String get dialog_item_enchantment_delete_title => 'Delete enchantment';

  @override
  String get dialog_item_enchantment_delete_header =>
      'Are you sure you want to delete this enchantment?';

  @override
  String get dialog_item_lore_edit_title => 'Edit lore';

  @override
  String get dialog_item_lore_delete_title => 'Delete lore';

  @override
  String get dialog_item_lore_delete_header =>
      'Are you sure you want to delete this lore?';

  @override
  String get dialog_font_create_title => 'Create new font';

  @override
  String get dialog_font_char_add => 'Add character';

  @override
  String get dialog_font_char_edit => 'Edit char';

  @override
  String get dialog_font_char_delete => 'Delete char';

  @override
  String get dialog_char_title => 'Add char';

  @override
  String get dialog_abort_chars_add => 'Unable to add char';

  @override
  String get dialog_abort_chars_text => 'There is already an entry called ';

  @override
  String get dialog_notification_create => 'Create new notification';

  @override
  String get dialog_group_change => 'Change group?';

  @override
  String get dialog_group_change_text =>
      'The model contains enchantments which are not in the new selected group.\nAll enchantments which are not in the group will be deleted.\n\nAre you sure you want to change the group?';

  @override
  String get card_name => 'Variable Name';

  @override
  String get card_description => 'Description';

  @override
  String get card_comment => 'Comment';

  @override
  String get card_material => 'Material';

  @override
  String get card_model_data => 'ModelData';

  @override
  String get card_amount => 'Amount';

  @override
  String get card_amount_to_high => 'The maximum amount is 64';

  @override
  String get card_display_name => 'DisplayName';

  @override
  String get card_title => 'Title';

  @override
  String get card_type => 'Type';

  @override
  String get card_group => 'Group';

  @override
  String get card_enchantments => 'Enchantments';

  @override
  String get card_lore => 'Lore';

  @override
  String get card_frame_type => 'FrameType';

  @override
  String get card_ascent => 'Ascent';

  @override
  String get card_height => 'Height';

  @override
  String get card_chars => 'Chars';

  @override
  String get card_attribute_default_value => 'Default value';

  @override
  String get card_attribute_maximum_value => 'Maximum value';

  @override
  String get card_font_provider => 'Provider';

  @override
  String get card_font_texture_path => 'Texture path';

  @override
  String get label_level => 'Level';

  @override
  String get item_level => 'Level: ';

  @override
  String get tooltip_delete => 'Delete';

  @override
  String get tooltip_name => 'Change the name for the variable';

  @override
  String get tooltip_description => 'Change description';

  @override
  String get tooltip_material => 'Change the material';

  @override
  String get tooltip_model_data => 'Change the model data';

  @override
  String get tooltip_displayname => 'Change the Displayname';

  @override
  String get tooltip_title => 'Change title';

  @override
  String get tooltip_amount => 'Change amount';

  @override
  String get tooltip_flag => 'Change the flags';

  @override
  String get tooltip_ascent => 'Change ascent';

  @override
  String get tooltip_height => 'Change height';

  @override
  String get tooltip_line_count => 'Current line count';

  @override
  String get tooltip_item_group => 'Change the group of an item';

  @override
  String get tooltip_item_enchantment_all_set =>
      'All enchantments has been set for this group!';

  @override
  String get empty_data_header => 'No data selected';

  @override
  String get empty_data_subHeader => 'Please create or selected a model';

  @override
  String get empty_data_no_enchantments => 'No enchantments added yet';

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
  String get settings_display_title => 'Display settings';

  @override
  String get settings_theme_item_title => 'Use System Theme';

  @override
  String get settings_theme_item_subtitle =>
      'Automatically match your system\'s theme settings';

  @override
  String get settings_item_dark_mode_title => 'Dark Mode';

  @override
  String get settings_item_dark_mode_subtitle => 'Update your preferred theme';

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
  String get settings_item_font_title => 'Font Size';

  @override
  String get settings_item_font_subtitle =>
      'Adjust the text size throughout the app';

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

  @override
  String get settings_misc_license_header => 'Third-party software licenses';

  @override
  String get settings_misc_license_body =>
      'This application uses the following open-source libraries.';

  @override
  String get settings_misc_license_button => 'View';

  @override
  String get settings_misc_version_header => 'App Version';

  @override
  String get settings_misc_version_body =>
      'Currently installed version of Stelaris';

  @override
  String get settings_end_tile_made_with => 'Made with';

  @override
  String get settings_end_tile_team => 'by the team';

  @override
  String get welcome_to_stelaris => 'Welcome to Stelaris';

  @override
  String get project_selection_title => 'Select Project';

  @override
  String get project_selection_empty_title => 'No projects found';

  @override
  String get project_selection_empty_subtitle =>
      'Get started by creating your first project.';

  @override
  String get project_selection_dropdown_label => 'Project / Namespace';

  @override
  String get project_selection_open_button => 'Open Project';

  @override
  String get dialog_project_create_title => 'Create new project';

  @override
  String get dialog_project_display_name => 'Display Name';

  @override
  String get dialog_project_key => 'Key / Namespace';

  @override
  String get dialog_project_description => 'Description';

  @override
  String get dialog_project_url => 'Project URL';

  @override
  String get dialog_project_docu_url => 'Documentation URL';

  @override
  String get dialog_project_labor => 'Labor / Experimental';

  @override
  String get dialog_project_create_button => 'Create';

  @override
  String get settings_project_title => 'Project';

  @override
  String get settings_project_active_title => 'Active Project';

  @override
  String get settings_project_active_subtitle =>
      'Select or switch the active project workspace';

  @override
  String get settings_misc_switch_project_header => 'Switch Project';

  @override
  String get settings_misc_switch_project_body =>
      'Change the currently selected project workspace';

  @override
  String get settings_misc_switch_project_button => 'Switch';

  @override
  String get dialog_project_switch_title => 'Switch project?';

  @override
  String get dialog_project_switch_hint =>
      'Loaded items, fonts, notifications, attributes and sound events will be reset.';

  @override
  String get dialog_project_switch_confirm => 'Switch project';
}
