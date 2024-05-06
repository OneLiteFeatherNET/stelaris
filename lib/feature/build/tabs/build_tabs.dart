import 'package:flutter/material.dart';

class BuildTabs extends StatelessWidget {
  const BuildTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar.secondary(
      dividerHeight: 0,
      tabs: [
        Tab(
          icon: Icon(Icons.download),
          text: 'Download',
        ),
        Tab(
          text: 'Build',
          icon: Icon(Icons.construction_sharp),
        ),
      ],
    );
  }
}
