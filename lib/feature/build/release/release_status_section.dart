import 'package:flutter/material.dart';
import 'package:stelaris/api/state/factory/build/build_vm_state.dart';
import 'package:stelaris/feature/build/release/release_metadata_display.dart';
import 'package:stelaris/feature/status_card.dart';
import 'package:stelaris/util/constants.dart';

class ReleaseStatusSection extends StatelessWidget {
  const ReleaseStatusSection({required this.vm, super.key});

  final BuildViewModel vm;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    if (vm.isLoadingRelease) {
      return StatusCard(
        text: 'Fetching release info...',
        backgroundColor: themeData.colorScheme.secondaryContainer.withValues(
          alpha: 0.5,
        ),
        textColor: themeData.colorScheme.onSecondaryContainer,
        height: 70,
      );
    }

    if (vm.releaseModel == null) {
      return ReleaseMetadataDisplay.version(
        releaseModel: vm.releaseModel,
        height: 70,
      );
    }

    return Row(
      children: [
        Expanded(
          child: ReleaseMetadataDisplay.version(
            releaseModel: vm.releaseModel,
            glowColor: themeData.colorScheme.secondary,
            height: 70,
          ),
        ),
        horizontalSpacing10,
        Expanded(
          child: ReleaseMetadataDisplay.status(
            releaseModel: vm.releaseModel,
            glowColor: themeData.colorScheme.secondary,
            height: 70,
          ),
        ),
      ],
    );
  }
}
