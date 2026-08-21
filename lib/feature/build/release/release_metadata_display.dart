import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stelaris_models/stelaris_models.dart';
import 'package:stelaris/feature/status_card.dart';
import 'package:stelaris/util/constants.dart';

enum ReleaseDisplayType { version, status }

class ReleaseMetadataDisplay extends StatelessWidget {
  final ReleaseModel? releaseModel;
  final Color? glowColor;
  final Color? backgroundColor;
  final double height;
  final ReleaseDisplayType _type;

  static final DateFormat _outputFormat = DateFormat(
    'yyyy-MM-dd HH:mm:ss',
    'en_US',
  );

  const ReleaseMetadataDisplay.version({
    required this.releaseModel,
    this.glowColor,
    this.backgroundColor,
    this.height = 100,
    super.key,
  }) : _type = ReleaseDisplayType.version;

  const ReleaseMetadataDisplay.status({
    required this.releaseModel,
    this.glowColor,
    this.backgroundColor,
    this.height = 100,
    super.key,
  }) : _type = ReleaseDisplayType.status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (releaseModel == null) {
      final colorScheme = theme.colorScheme;
      return StatusCard(
        text: 'Service unavailable',
        backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.8),
        textColor: colorScheme.onErrorContainer,
        height: height,
      );
    }

    final model = releaseModel!;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius12,
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Card.filled(
          color: Colors.transparent,
          elevation: 0,
          key: ValueKey('${model.version}_$_type'),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(child: _buildContent(context, model)),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReleaseModel model) {
    return _type == ReleaseDisplayType.version
        ? _buildVersionContent(context, model)
        : _buildStatusContent(context, model);
  }

  Widget _buildVersionContent(BuildContext context, ReleaseModel model) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Build: ${model.version}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Release: ${_format(model.publishedAt)}',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatusContent(BuildContext context, ReleaseModel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusRow(context, model),
        const SizedBox(height: 6),
        _buildCommitInfo(context, model),
      ],
    );
  }

  Widget _buildStatusRow(BuildContext context, ReleaseModel model) {
    final theme = Theme.of(context);
    final isPrerelease = model.prerelease;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
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
            height: 1,
          ),
        ),
        const SizedBox(width: 6),
        Icon(
          isPrerelease ? Icons.science : Icons.check_circle,
          size: 18,
          color: isPrerelease ? Colors.orange : Colors.green,
        ),
      ],
    );
  }

  Widget _buildCommitInfo(BuildContext context, ReleaseModel model) {
    final theme = Theme.of(context);
    final commit =
        model.targetCommitish; // Using targetCommitish as per user edit

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
        Text('Commit: ', style: theme.textTheme.bodySmall),
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

  String _format(DateTime input) {
    return _outputFormat.format(input);
  }
}
