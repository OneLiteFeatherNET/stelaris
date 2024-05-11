import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/app_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/settings/row/settings_base_row.dart';
import 'package:stelaris_ui/feature/settings/settings_divider.dart';
import 'package:stelaris_ui/feature/settings/settings_end_tile.dart';
import 'package:stelaris_ui/feature/settings/settings_header_tile.dart';
import 'package:stelaris_ui/feature/settings/settings_text_tile.dart';
import 'package:stelaris_ui/util/l10n_ext.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/url_launcher.dart';

const settingsDivider = SettingsDivider();

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, bool>(
      converter: (store) => store.state.nightMode,
      builder: (context, vm) {
        return Dialog(
          clipBehavior: Clip.hardEdge,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 1000,
              minHeight: 600,
              maxHeight: 600,
              maxWidth: 1000,
            ),
            child: Column(
              children: [
                const SettingsHeaderTile(),
                verticalSpacing25,
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heightTen,
                      SettingsBaseRow(
                        title: context.l10n.settings_display_title,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SettingsTextTile(
                              headerLine: context.l10n.settings_display_header,
                              bodyLine: context.l10n.settings_display_body,
                            ),
                            const Spacer(),
                            settingsDivider,
                            Switch(
                              value: vm,
                              onChanged: (value) {
                                StoreProvider.dispatch(
                                  context,
                                  ChangeThemeStateAction(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      verticalSpacing25,
                      SettingsBaseRow(
                        title: context.l10n.settings_accessibility_title,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SettingsTextTile(
                              headerLine:
                                  context.l10n.settings_accessibility_body,
                              bodyLine:
                                  context.l10n.settings_accessibility_header,
                            ),
                            OutlinedButton(
                              onPressed: () =>
                                  UriLauncher().launchUrlInTab(conceptURL),
                              child: Text(
                                  context.l10n.settings_accessibility_button),
                            ),
                          ],
                        ),
                      ),
                      verticalSpacing25,
                      SettingsBaseRow(
                        title: context.l10n.settings_misc_title,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SettingsTextTile(
                                  headerLine:
                                      context.l10n.settings_misc_bug_header,
                                  bodyLine: context.l10n.settings_misc_bug_body,
                                ),
                                OutlinedButton(
                                  onPressed: () =>
                                      UriLauncher().launchUrlInTab(gitUrl),
                                  child: Text(
                                      context.l10n.settings_misc_bug_button),
                                ),
                              ],
                            ),
                            verticalSpacing25,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SettingsTextTile(
                                  headerLine: context
                                      .l10n.settings_misc_suggestion_header,
                                  bodyLine: context
                                      .l10n.settings_misc_suggestion_body,
                                ),
                                OutlinedButton(
                                  onPressed: () =>
                                      UriLauncher().launchUrlInTab(gitUrl),
                                  child: Text(context
                                      .l10n.settings_misc_suggestion_button),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: fiftyLength,
                      ),
                      const SettingsEndTile(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
