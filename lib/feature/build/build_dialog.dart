import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:stelaris/api/state/actions/build/build_actions.dart';
import 'package:stelaris/api/state/app_state.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/feature/base/dialog/animated_dialog.dart';
import 'package:stelaris/feature/build/build_information.dart';
import 'package:stelaris/feature/build/download/download_trigger.dart';
import 'package:stelaris/feature/build/parts/build_trigger.dart';
import 'package:stelaris/feature/build/tabs/build_tabs.dart';
import 'package:stelaris/feature/settings/settings_header_tile.dart';
import 'package:stelaris/feature/status_card.dart';
import 'package:stelaris/util/constants.dart';

class BuildDialog extends StatelessWidget {
  const BuildDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedDialog(
      maxHeight: 700,
      minHeightFactor: 0.6,
      child: StoreConnector<AppState, BuildViewModel>(
        vm: () => BuildStateFactory(),
        onInit: (store) {
          store.dispatchAll([ReleaseFetchAction(), BranchFetchAction()]);
        },
        builder: (context, vm) {
          final ThemeData themeData = Theme.of(context);
          return DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SettingsHeaderTile(text: 'Build & Download Vulpes'),
                verticalSpacing25,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: vm.releaseModel == null
                      ? BuildInformationDisplay(
                          releaseModel: vm.releaseModel,
                          height: 70,
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: BuildInformationDisplay(
                                releaseModel: vm.releaseModel,
                                glowColor: themeData.colorScheme.primary,
                                height: 70,
                              ),
                            ),
                            horizontalSpacing10,
                            Expanded(
                              child: StatusCard(
                                text: 'Additional Changes',
                                glowColor: themeData.colorScheme.secondary,
                                height: 70,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 15),
                divider,
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: BuildTabs(),
                ),
                divider,
                Expanded(
                  child: TabBarView(
                    children: [
                      DownloadTrigger(branches: vm.branches),
                      BuildTrigger(version: vm.version),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
