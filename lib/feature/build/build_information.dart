import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stelaris/api/model/release/release_model.dart';

DateFormat inputFormat = DateFormat("EEE MMM dd HH:mm:ss 'CEST' yyyy", 'en_US');
DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US');

class BuildInformationDisplay extends StatelessWidget {
  final ReleaseModel releaseModel;

  const BuildInformationDisplay({
    required this.releaseModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Increased height for Card
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Card.filled(
          key: ValueKey(releaseModel.version),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Build: ${releaseModel.version}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Release: ${_format(releaseModel.publishedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
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
