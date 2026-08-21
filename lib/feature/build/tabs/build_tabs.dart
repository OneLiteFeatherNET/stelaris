import 'package:material_ui/material_ui.dart';

class BuildTabs extends StatelessWidget {
  const BuildTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBar.secondary(
      dividerHeight: 0,
      tabs: [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.download),
              SizedBox(width: 8),
              Text('Download'),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction_sharp),
              SizedBox(width: 8),
              Text('Build'),
            ],
          ),
        ),
      ],
    );
  }
}
