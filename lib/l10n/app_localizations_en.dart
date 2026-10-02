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
  String get feedback_save_success => 'Changes saved successfully';

  @override
  String get feedback_save_error => 'Failed to save changes';

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
  String get auth_sign_in => 'Sign in';

  @override
  String get auth_sign_out => 'Sign out';

  @override
  String get auth_retry => 'Try again';

  @override
  String get auth_account => 'Account';

  @override
  String get auth_signed_in => 'Signed in';

  @override
  String get auth_no_roles => 'No roles granted';

  @override
  String auth_roles_more(int count) {
    return 'and $count more';
  }

  @override
  String get auth_sign_in_required => 'Sign in to continue.';

  @override
  String get auth_session_expired =>
      'Your session expired. Sign in again to continue.';

  @override
  String get auth_provider_unavailable =>
      'The identity provider could not be reached. Check the deployment configuration, then try again.';

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
  String get delete_dialog_first_line => 'Are you sure you want to delete ';

  @override
  String get delete_dialog_entry => '?';

  @override
  String get delete_dialog_irreversible => 'This action cannot be undone.';

  @override
  String get delete_dialog_type_name_before => 'To confirm, type \"';

  @override
  String get delete_dialog_type_name_after => '\" in the box below';

  @override
  String get delete_dialog_related_font =>
      'All characters that belong to this font will also be deleted.';

  @override
  String get delete_dialog_related_item =>
      'All lore entries and enchantments that belong to this item will also be deleted.';

  @override
  String get delete_dialog_related_sound =>
      'All sound files that belong to this event will also be deleted.';

  @override
  String get dialog_attribute_delete_title => 'Delete attribute';

  @override
  String get dialog_font_delete_title => 'Delete font';

  @override
  String get dialog_item_delete_title => 'Delete item';

  @override
  String get dialog_notification_delete_title => 'Delete notification';

  @override
  String get dialog_sound_delete_title => 'Delete sound event';

  @override
  String get dialog_attribute_create => 'Create attribute';

  @override
  String get dialog_attribute_edit_title => 'Edit attribute';

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
  String get dialog_item_enchantment_unsafe => 'Unsafe';

  @override
  String get dialog_item_enchantment_unsafe_hint =>
      'Allows levels above the normal maximum of the enchantment';

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
  String get action_notes => 'Notes';

  @override
  String get notes_hint =>
      'Internal notes for your team. The first line is shown in the overview.';

  @override
  String get tab_general => 'General';

  @override
  String get tab_enchantments => 'Enchantments';

  @override
  String get tab_lore => 'Lore';

  @override
  String get tab_characters => 'Characters';

  @override
  String get tab_entries => 'Entries';

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

  @override
  String get dialog_project_edit_title => 'Edit project';

  @override
  String get dialog_project_edit_button => 'Save';

  @override
  String get dialog_project_key_readonly_hint =>
      'Project key cannot be changed after creation';

  @override
  String get project_selection_edit_tooltip => 'Edit project';

  @override
  String get dialog_sound_create => 'Create new sound event';

  @override
  String get dialog_model_key_label => 'Key';

  @override
  String get dialog_model_key_hint => 'e.g. my_entry';

  @override
  String get dialog_model_name_label => 'Name';

  @override
  String get dialog_model_name_hint => 'e.g. My Entry';

  @override
  String get dialog_model_preview_label => 'NamespacedKey Preview';

  @override
  String get dialog_model_create_button => 'Create';

  @override
  String get tooltip_more_actions => 'More actions';

  @override
  String get menu_item_info => 'Info';

  @override
  String get menu_item_edit_notes => 'Edit notes';

  @override
  String get notes_edit_in_overview =>
      'To edit the notes, use ⋯ → Edit notes on the overview card.';

  @override
  String get tooltip_notes_present => 'Has notes';

  @override
  String dialog_notes_title(String name) {
    return 'Notes for $name';
  }

  @override
  String get dialog_model_info_id_label => 'ID';

  @override
  String get dialog_model_info_created_label => 'Created';

  @override
  String get dialog_model_info_modified_label => 'Modified';

  @override
  String get dialog_model_info_relationships_label => 'Relationships';

  @override
  String get dialog_model_info_relationships_yes => 'Yes';

  @override
  String get dialog_model_info_relationships_no => 'No';

  @override
  String get button_close => 'Close';

  @override
  String get tooltip_copy_to_clipboard => 'Copy to clipboard';

  @override
  String get snackbar_copied_to_clipboard => 'Copied to clipboard';

  @override
  String get command_bar_search_tooltip => 'Focus search';

  @override
  String get command_bar_filter_sort_tooltip => 'Filter & Sort';

  @override
  String get command_bar_refresh_tooltip => 'Refresh';

  @override
  String get command_palette_no_results => 'No matching commands';

  @override
  String get command_palette_group_navigation => 'Navigation';

  @override
  String get command_palette_group_interface => 'Interface';

  @override
  String get command_palette_group_backend => 'Backend';

  @override
  String command_go_to(String page) {
    return 'Go to $page';
  }

  @override
  String get command_go_to_keywords => 'navigate open page';

  @override
  String get command_go_to_projects => 'Go to project list';

  @override
  String get command_go_to_projects_keywords => 'switch change select project';

  @override
  String get command_toggle_dark_mode => 'Toggle dark mode';

  @override
  String get command_toggle_dark_mode_keywords =>
      'theme light night appearance';

  @override
  String get command_toggle_system_theme => 'Toggle system theme';

  @override
  String get command_toggle_system_theme_keywords =>
      'follow system appearance automatic';

  @override
  String get command_open_settings => 'Open settings';

  @override
  String get command_open_settings_keywords =>
      'preferences options configuration';

  @override
  String get command_open_build => 'Open build dialog';

  @override
  String get command_open_build_keywords => 'generate release download code';

  @override
  String get command_reload_list => 'Reload current list';

  @override
  String get command_reload_list_keywords => 'refresh fetch update';

  @override
  String get command_reload_list_success => 'List reloaded';

  @override
  String get command_reload_list_failure => 'Could not reload the list';

  @override
  String get command_reload_branches => 'Reload git branches';

  @override
  String get command_reload_branches_keywords => 'refresh fetch git branch';

  @override
  String get command_reload_branches_success => 'Branches reloaded';

  @override
  String get command_reload_branches_failure => 'Could not reload the branches';

  @override
  String get command_reload_release => 'Reload release information';

  @override
  String get command_reload_release_keywords => 'refresh fetch build version';

  @override
  String get command_reload_release_success => 'Release information reloaded';

  @override
  String get command_reload_release_unchanged => 'No new release information';

  @override
  String get command_palette_group_entities => 'Entities';

  @override
  String get command_palette_group_projects => 'Projects';

  @override
  String get command_palette_group_help => 'Syntax';

  @override
  String get command_palette_mode_commands => 'Commands';

  @override
  String get command_palette_mode_commands_help => 'Run a command';

  @override
  String get command_palette_mode_entities => 'Entities';

  @override
  String get command_palette_mode_entities_help =>
      'Open an item, font, sound, notification or attribute';

  @override
  String get command_palette_mode_projects => 'Projects';

  @override
  String get command_palette_mode_projects_help => 'Switch to another project';

  @override
  String get command_palette_mode_settings => 'Settings';

  @override
  String get command_palette_mode_settings_help =>
      'Change the theme or open the settings';

  @override
  String get command_palette_mode_help => 'Help';

  @override
  String get command_palette_kind_items => 'Items';

  @override
  String get command_palette_kind_fonts => 'Fonts';

  @override
  String get command_palette_kind_sounds => 'Sounds';

  @override
  String get command_palette_kind_notifications => 'Notifications';

  @override
  String get command_palette_kind_attributes => 'Attributes';

  @override
  String command_palette_aliases(String aliases) {
    return 'Also: $aliases';
  }

  @override
  String get command_palette_loaded_only =>
      'Only entries that are already loaded are searched';

  @override
  String get command_palette_searching => 'Searching…';

  @override
  String get command_palette_search_failed =>
      'The search service is unavailable; showing loaded entries';

  @override
  String command_palette_capped(int shown, int matched) {
    return '$shown of $matched shown';
  }

  @override
  String command_palette_fallback_entities(String text) {
    return 'Search entities for “$text”';
  }

  @override
  String command_palette_fallback_projects(String text) {
    return 'Search projects for “$text”';
  }

  @override
  String get command_palette_remove_mode => 'Leave this mode';

  @override
  String get command_palette_hint_default =>
      'Type a command, or ? to see what else you can search';

  @override
  String get command_palette_hint_commands => 'Search commands';

  @override
  String get command_palette_hint_entities =>
      'Search loaded items, fonts, sounds, notifications and attributes';

  @override
  String command_palette_hint_kind(String kind) {
    return 'Search loaded $kind';
  }

  @override
  String get command_palette_hint_projects => 'Search a project to switch to';

  @override
  String get command_palette_hint_settings => 'Search settings';

  @override
  String get command_palette_hint_help => 'Pick a mode, or type its prefix';

  @override
  String get command_palette_mode_navigation => 'Navigation';

  @override
  String get command_palette_mode_navigation_help => 'Go to a page';

  @override
  String get command_palette_hint_navigation => 'Search pages to go to';

  @override
  String get command_palette_help_keyboard => 'Keyboard';

  @override
  String get command_palette_key_move => 'Move the highlight';

  @override
  String get command_palette_key_run => 'Run the highlighted entry';

  @override
  String get command_palette_key_close => 'Close the palette';

  @override
  String get command_palette_key_leave =>
      'Leave the mode when the field is empty';

  @override
  String get command_palette_key_toggle => 'Open or close the palette';

  @override
  String get command_palette_footer_move => 'Navigate';

  @override
  String get command_palette_footer_run => 'Run';

  @override
  String get command_palette_footer_close => 'Close';

  @override
  String get command_palette_footer_help => 'Help';

  @override
  String get command_palette_footer_step_in => 'More';

  @override
  String get command_palette_footer_step_out => 'Back';

  @override
  String get command_palette_current_page => 'Current page';

  @override
  String get command_palette_group_create => 'Create';

  @override
  String command_palette_hint_section(String section) {
    return 'Search $section, or ? for more';
  }

  @override
  String command_palette_filter_list(String section, String text) {
    return 'Filter $section by “$text”';
  }

  @override
  String command_palette_show_matching(String section, String text) {
    return 'Show $section matching “$text”';
  }

  @override
  String get command_create_item => 'New item';

  @override
  String get command_create_font => 'New font';

  @override
  String get command_create_sound => 'New sound';

  @override
  String get command_create_notification => 'New notification';

  @override
  String get command_create_attribute => 'New attribute';

  @override
  String get command_create_keywords => 'create add new';

  @override
  String get command_delete_entry => 'Delete…';

  @override
  String get command_delete_keywords => 'delete remove';

  @override
  String get command_delete_this_item => 'Delete this item…';

  @override
  String get command_delete_this_font => 'Delete this font…';

  @override
  String get command_delete_this_sound => 'Delete this sound…';

  @override
  String get command_delete_this_notification => 'Delete this notification…';

  @override
  String get command_palette_key_step_in =>
      'Show the tabs of the highlighted entry';

  @override
  String get command_palette_key_step_out =>
      'Back to the list, with the cursor at the start';

  @override
  String command_palette_hint_drill(String name) {
    return '$name: pick a tab or an action';
  }

  @override
  String get sort_name_ascending => 'Name (A–Z)';

  @override
  String get sort_name_descending => 'Name (Z–A)';

  @override
  String get sort_created_newest_first => 'Created (newest first)';

  @override
  String get sort_created_oldest_first => 'Created (oldest first)';

  @override
  String get filter_attribute_has_default_value => 'Has default value';

  @override
  String get filter_attribute_has_maximum_value => 'Has maximum value';

  @override
  String get model_card_created_prefix => 'Created';

  @override
  String get model_card_edited_prefix => 'Edited';

  @override
  String get relative_time_just_now => 'Just now';

  @override
  String relative_time_minutes_ago(int count) {
    return '$count min ago';
  }

  @override
  String relative_time_hours_ago(int count) {
    return '$count h ago';
  }

  @override
  String relative_time_days_ago(int count) {
    return '$count d ago';
  }

  @override
  String get button_delete => 'Delete';

  @override
  String get button_discard => 'Discard';

  @override
  String get unsaved_dialog_title => 'Unsaved changes';

  @override
  String get unsaved_dialog_message =>
      'You have unsaved changes. Do you want to save them before leaving?';

  @override
  String get unsaved_indicator_tooltip => 'Unsaved changes';

  @override
  String app_bar_search_hint(String section) {
    return 'Search $section...';
  }

  @override
  String get app_bar_search_close_tooltip => 'Close search';

  @override
  String get search_clear_tooltip => 'Clear search';

  @override
  String get search_no_results => 'No matches';

  @override
  String get search_no_results_hint =>
      'Try another search or reset the filters.';

  @override
  String get search_reset => 'Reset search';

  @override
  String get button_edit => 'Edit';

  @override
  String get button_view => 'View';

  @override
  String get error_title => 'Error';

  @override
  String get settings_title => 'Settings';

  @override
  String get empty_data_default_header => 'No data available';

  @override
  String get empty_data_default_subheader =>
      'Use the add button to add new data!';

  @override
  String get validation_required => 'This field is required';

  @override
  String get validation_name_required => 'Name is required';

  @override
  String get validation_display_name_required => 'Display name is required';

  @override
  String get validation_key_required => 'Key is required';

  @override
  String get validation_namespace_required => 'Key / Namespace is required';

  @override
  String get validation_no_uppercase => 'Uppercase letters are not allowed';

  @override
  String get validation_no_uppercase_key =>
      'Uppercase letters are not allowed in Adventure keys';

  @override
  String get validation_no_spaces => 'Spaces are not allowed';

  @override
  String get validation_no_double_dots => 'Double dots (..) are not allowed';

  @override
  String get validation_one_colon =>
      'Only one colon (:) is allowed for namespace:key';

  @override
  String get validation_namespace_slash_in_key =>
      'Namespace cannot contain slashes (/)';

  @override
  String get validation_namespace_no_colon =>
      'Colons (:) are not allowed (only the namespace part, e.g. \"my_project\")';

  @override
  String get validation_namespace_no_slash =>
      'Slashes (/) are not allowed in a namespace';

  @override
  String get validation_key_part_no_colon =>
      'Colons (:) are not allowed in the key part';

  @override
  String get validation_adventure_key_invalid =>
      'Invalid Adventure key (e.g. \"my_project\" or \"custom:my_project\")';

  @override
  String get validation_namespace_invalid =>
      'Invalid namespace (only lowercase letters, numbers, [._-] allowed, e.g. \"my_project\")';

  @override
  String get validation_key_part_invalid =>
      'Invalid key (only lowercase letters, numbers, [._/-] allowed, e.g. \"magic_wand\")';

  @override
  String get validation_texture_path_invalid =>
      'Invalid texture path (e.g. \"minecraft:font/ascii.png\")';

  @override
  String get validation_sound_key_invalid =>
      'Invalid key (e.g. \"entity.player.hurt\" or \"custom:ui/click\")';

  @override
  String get validation_level_required => 'Please enter a level';

  @override
  String get validation_number_invalid => 'Please enter a valid number';

  @override
  String validation_maximum(int max) {
    return 'The maximum is $max';
  }

  @override
  String validation_field_required(String field) {
    return 'Enter a $field';
  }

  @override
  String get validation_integer_invalid => 'Enter a valid integer';

  @override
  String get validation_codepoint_required => 'Please enter a codepoint';

  @override
  String get validation_codepoint_invalid =>
      'Enter exactly 4 hex digits (e.g. E000)';

  @override
  String get validation_commit_length =>
      'The commit must contain 10 characters';

  @override
  String get project_description_hint => 'Brief description of the project';

  @override
  String get project_labor_toggle =>
      'Mark as laboratory / experimental project';

  @override
  String project_badge_tooltip(String name, String key) {
    return 'Project: $name ($key)\nClick to open settings';
  }

  @override
  String get project_labor_badge => 'Labor';

  @override
  String get build_service_unavailable => 'Service unavailable';

  @override
  String build_release_version(String version) {
    return 'Build: $version';
  }

  @override
  String build_release_date(String date) {
    return 'Release: $date';
  }

  @override
  String get build_release_status => 'Status: ';

  @override
  String get build_release_prerelease => 'Pre-Release';

  @override
  String get build_release_stable => 'Stable';

  @override
  String get build_no_commit_info => 'No commit info';

  @override
  String get build_commit_label => 'Commit: ';

  @override
  String get build_fetching_release => 'Fetching release info...';

  @override
  String get build_current_version => 'Current version';

  @override
  String get build_new_version => 'New Version';

  @override
  String get build_version_part_prompt =>
      'Select the part of the version to update:';

  @override
  String get build_started => 'Build started successfully';

  @override
  String build_failed(String error) {
    return 'Build failed: $error';
  }

  @override
  String get build_tab_build => 'Build';

  @override
  String get build_dialog_title => 'Build & Download Vulpes';

  @override
  String get download_commit_label => 'Git commit';

  @override
  String get download_commit_tooltip =>
      'Enter a valid Git commit (Only the first 10 characters)';

  @override
  String get download_fetching_branches => 'Fetching branches...';

  @override
  String get download_no_project =>
      'No project selected! Please select a project first';

  @override
  String get download_no_branches =>
      'No branches found! Please create some in the repository';

  @override
  String get download_refresh_branches => 'Refresh branches';

  @override
  String get download_search_by_commit => 'Search by Commit';

  @override
  String get sound_key => 'Key';

  @override
  String get sound_subtitle => 'Subtitle';

  @override
  String get sound_file_delete_title => 'Delete file';

  @override
  String get sound_file_delete_body => 'Unlink this file from the sound event?';

  @override
  String get sound_section_weight_attenuation => 'Weight & Attenuation';

  @override
  String get sound_weight => 'Weight';

  @override
  String get sound_attenuation_distance => 'Attenuation Distance';

  @override
  String get sound_section_volume_pitch => 'Volume & Pitch';

  @override
  String get sound_volume => 'Volume';

  @override
  String get sound_pitch => 'Pitch';

  @override
  String get sound_name => 'Name';

  @override
  String get sound_name_hint => 'Enter your sound name';

  @override
  String get sound_name_tooltip => 'The name of the sound';

  @override
  String get sound_stream => 'Stream';

  @override
  String get sound_preload => 'Preload';

  @override
  String get sound_create => 'Create Sound';

  @override
  String get sound_edit => 'Edit Sound';

  @override
  String get sound_options => 'Options';

  @override
  String get sound_type_file => 'File';

  @override
  String get sound_type_event => 'Event';

  @override
  String get font_char_label => 'Char *';
}
