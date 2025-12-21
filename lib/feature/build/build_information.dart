import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stelaris/api/model/release/release_model.dart';

import '../status_card.dart';

DateFormat inputFormat = DateFormat("EEE MMM dd HH:mm:ss 'CEST' yyyy", 'en_US');
DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US');

class BuildInformationDisplay extends StatelessWidget {
  final ReleaseModel? releaseModel;

  const BuildInformationDisplay({
    required this.releaseModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (releaseModel == null) {
      final colorScheme = theme.colorScheme;
      return StatusCard(
        text: 'Service unavailable',
        backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.8),
        textColor: colorScheme.onErrorContainer,
      );
    }
    return SizedBox(
      height: 100, // Increased height for Card
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Card.filled(
          key: ValueKey(releaseModel!.version),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Build: ${releaseModel!.version}',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Release: ${_format(releaseModel!.publishedAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _format(DateTime input) {
    return outputFormat.format(input);
  }
}
