import 'package:flutter/material.dart';

class SettingsEndTile extends StatelessWidget {
  const SettingsEndTile({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '@2025 Onelitefeather',
                style: textTheme.bodyMedium,
              ),
              TextSpan(
                text: ' • ',
                style: textTheme.bodyMedium,
              ),
              TextSpan(
                text: 'Made with',
                style: textTheme.bodyMedium,
              ),
              const TextSpan(
                text: ' \u2764 ',
                style: TextStyle(color: Colors.red),
              ),
              TextSpan(
                text: 'by the team',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
