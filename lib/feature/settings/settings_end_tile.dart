import 'package:flutter/material.dart';

class SettingsEndTile extends StatelessWidget {
  const SettingsEndTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '@2024 Onelitefeather',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextSpan(
                text: ' • ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              TextSpan(
                text: 'Made with',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const TextSpan(
                text: ' \u2764 ',
                style: TextStyle(color: Colors.red),
              ),
              TextSpan(
                text: 'by the team',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )
      ],
    );
  }
}
