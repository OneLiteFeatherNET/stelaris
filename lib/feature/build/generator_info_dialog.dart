import 'package:material_ui/material_ui.dart';
import 'package:stelaris/feature/base/dialog/info_dialog.dart';
import 'package:stelaris/feature/base/dialog/notice_box.dart';
import 'package:stelaris/l10n/app_localizations.dart';
import 'package:stelaris/util/l10n_ext.dart';

/// Explains the generator page: what it is for and what each tab does, and,
/// in demo mode, that nothing reaches the real generator.
class GeneratorInfoDialog extends StatelessWidget {
  const GeneratorInfoDialog({required this.demo, super.key});

  /// Whether the page simulates the generator.
  final bool demo;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return InfoDialog(
      title: l10n.generator_info_title,
      intro: l10n.generator_info_intro,
      topics: [
        InfoTopic(
          icon: Icons.download_outlined,
          title: l10n.generator_tab_local,
          text: l10n.generator_info_local,
        ),
        InfoTopic(
          icon: Icons.publish_outlined,
          title: l10n.generator_tab_publish,
          text: l10n.generator_info_publish,
        ),
        InfoTopic(
          icon: Icons.history,
          title: l10n.generator_tab_versions,
          text: l10n.generator_info_versions,
        ),
      ],
      footer: demo
          ? NoticeBox(
              icon: Icons.science_outlined,
              color: Theme.of(context).colorScheme.tertiary,
              content: Text(l10n.generator_info_demo),
            )
          : null,
    );
  }
}
