import 'package:flutter/material.dart';
import 'package:stelaris_ui/feature/build/build_information.dart';
import 'package:stelaris_ui/feature/build/parts/build_trigger.dart';
import 'package:stelaris_ui/feature/build/parts/download_trigger.dart';
import 'package:stelaris_ui/feature/build/tabs/build_tabs.dart';
import 'package:stelaris_ui/util/constants.dart';

class BuildDrawer extends StatelessWidget {
  const BuildDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: DefaultTabController(
        initialIndex: 0,
        length: 2, // Number of tabs
        child: Column(
          children: [
            SizedBox(
              height: sizeFifty,
              child: ListTile(
                title: Text(
                  'Vulpes Build',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ListTile(
              title: BuildInformationDisplay(),
            ),
            divider,
            heightTen,
            Text(
              'What do you want to do?',
              textAlign: TextAlign.center,
            ),
            heightTen,
            divider,
            BuildTabs(),
            heightTen,
            divider,
            heightTen,
            Expanded(
              flex: 1, // Adjust this value as needed
              child: TabBarView(
                children: [
                  DownloadTrigger(),
                  BuildTrigger(version: '1.20.5') // Your DownloadTrigger widget
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
