import 'package:flutter/material.dart';
import 'package:stelaris/api/model/release/release_model.dart';

class ReleaseMetadataDisplay extends StatelessWidget {
  final ReleaseModel releaseModel;
  final Color? glowColor;
  final Color? backgroundColor;
  final double height;

  const ReleaseMetadataDisplay({
    required this.releaseModel,
    this.glowColor,
    this.backgroundColor,
    this.height = 100,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Card.filled(
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),  // Exakt wie StatusCard
          child: Center(  // Center wie in StatusCard
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReleaseTypeBadge(context),
                const SizedBox(height: 6),
                _buildCommitInfo(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReleaseTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isPrerelease = releaseModel.prerelease;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center, // Align vertically
      children: [
        Text(
          'Status: ',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          isPrerelease ? 'Pre-Release' : 'Stable',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isPrerelease ? Colors.orange : Colors.green,
            height: 1.0, // Adjust line height to align better with bodySmall if needed
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          isPrerelease ? Icons.science : Icons.check_circle,
          size: 18, // Slightly larger to match titleMedium
          color: isPrerelease ? Colors.orange : Colors.green,
        ),
      ],
    );
  }

  Widget _buildCommitInfo(BuildContext context) {
    final theme = Theme.of(context);
    final commit = releaseModel.targetCommitish;

    if (commit == null || commit.isEmpty) {
      return Text(
        'No commit info',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      );
    }

    final displayCommit = commit.length > 7 && !commit.contains('/')
        ? commit.substring(0, 7)
        : commit;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Commit: ',
           style: theme.textTheme.bodySmall,
        ),
        Icon(
          Icons.commit,
          size: 14,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          displayCommit,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}