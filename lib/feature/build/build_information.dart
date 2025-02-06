import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stelaris/api/api_service.dart';
import 'package:stelaris/api/model/build_information.dart';
import 'package:stelaris/util/constants.dart';

DateFormat inputFormat = DateFormat("EEE MMM dd HH:mm:ss 'CEST' yyyy", 'en_US');
DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US');

class BuildInformationDisplay extends StatelessWidget {
  const BuildInformationDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BuildInformation>(
      future: ApiService().generateApi.buildInformation(),
      builder: (context, AsyncSnapshot<BuildInformation> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: loader,
          );
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

        final BuildInformation buildInformation = snapshot.data as BuildInformation;

        return SizedBox(
          height: sizeFifty,
          child: Column(
            children: [
              Text("Build: ${buildInformation.data!["version"]}"),
              Text("Release: ${_format(buildInformation.data!["created"]!)}"),
            ],
          ),
        );
      },
    );
  }

  String _format(String input) {
    final formattedDate = inputFormat.parse(input);
    return outputFormat.format(formattedDate);
  }
}
