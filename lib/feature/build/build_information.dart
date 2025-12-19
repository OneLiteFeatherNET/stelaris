import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/release/release_model.dart';
import 'package:stelaris/feature/base/stelaris_loader.dart';

DateFormat inputFormat = DateFormat("EEE MMM dd HH:mm:ss 'CEST' yyyy", 'en_US');
DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US');

class BuildInformationDisplay extends StatelessWidget {
  const BuildInformationDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ReleaseModel>(
      future: ApiService().generateApi.buildInformation(),
      builder: (context, AsyncSnapshot<ReleaseModel> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const StelarisLoader();
        }
        if (snapshot.hasError) {
          return const Align(
            alignment: Alignment.center,
            child: Text('Service unavailable'),
          );
        }

        if (!snapshot.hasData) {
          return const Align(
            alignment: Alignment.center,
            child: Text('No releases found'),
          );
        }

        final ReleaseModel buildInformation = snapshot.data as ReleaseModel;

        return SizedBox(
          height: 100, // Increased height for Card
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Card.filled(
              key: ValueKey(buildInformation.version),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Build: ${buildInformation.version}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Release: ${_format(buildInformation.publishedAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _format(DateTime input) {
    return outputFormat.format(input);
  }
}
