import 'package:flutter/material.dart';
import 'package:stelaris/feature/build/build_information.dart';
import 'package:stelaris/feature/build/parts/build_drawer_header.dart';
import 'package:stelaris/feature/build/parts/build_trigger.dart';
import 'package:stelaris/feature/build/parts/download_trigger.dart';
import 'package:stelaris/feature/build/tabs/build_tabs.dart';
import 'package:stelaris/util/constants.dart';

class BuildDrawer extends StatelessWidget {
  const BuildDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: DefaultTabController(
        initialIndex: 0,
        length: 1,
        child: Column(
          children: [
            const BuildDrawerHeader(),
            const ListTile(
              title: BuildInformationDisplay(),
            ),
            const Divider(indent: 16, endIndent: 16),
            heightTen,
            Text(
              'What do you want to do?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            heightTen,
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: BuildTabs(),
            ),
            heightTen,
            divider,
            heightTen,
            const Expanded(
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
