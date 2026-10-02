import 'package:material_ui/material_ui.dart';
import 'package:stelaris/util/l10n_ext.dart';

class BuildTabs extends StatelessWidget {
  const BuildTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar.secondary(
      dividerHeight: 0,
      tabs: [
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.download),
              const SizedBox(width: 8),
              Text(context.l10n.button_download),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction_sharp),
              const SizedBox(width: 8),
              Text(context.l10n.build_tab_build),
            ],
          ),
        ),
      ],
    );
  }
}
