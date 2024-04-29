import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris_ui/api/state/actions/app_actions.dart';
import 'package:stelaris_ui/api/state/app_state.dart';
import 'package:stelaris_ui/feature/settings/row/settings_base_row.dart';
import 'package:stelaris_ui/feature/settings/settings_end_tile.dart';
import 'package:stelaris_ui/feature/settings/settings_header_tile.dart';
import 'package:stelaris_ui/util/constants.dart';
import 'package:stelaris_ui/util/url_launcher.dart';

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
              minHeight: 500,
              maxHeight: 500,
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
                      Text(
                        'Display options',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      const Divider(thickness: 1),
                      heightTen,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dark Mode',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Switch(
                              value: vm,
                              onChanged: (value) {
                                StoreProvider.dispatch(
                                    context, ChangeThemeStateAction());
                              }),
                        ],
                      ),
                      verticalSpacing25,
                      SettingsBaseRow(
                        title: 'Accessibility',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Need some help?'),
                            OutlinedButton(
                              onPressed: () =>
                                  UriLauncher().launchUrlInTab(conceptURL),
                              child: const Text('Wiki'),
                            ),
                          ],
                        ),
                      ),
                      verticalSpacing25,
                      SettingsBaseRow(
                        title: 'Misc',
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Found a bug?'),
                                OutlinedButton(
                                  onPressed: () =>
                                      UriLauncher().launchUrlInTab(gitUrl),
                                  child: const Text('Report'),
                                ),
                              ],
                            ),
                            verticalSpacing25,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Any Suggestion?'),
                                OutlinedButton(
                                  onPressed: () =>
                                      UriLauncher().launchUrlInTab(gitUrl),
                                  child: const Text('Suggest'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
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
