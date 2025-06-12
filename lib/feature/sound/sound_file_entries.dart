import 'package:flutter/material.dart';
import 'package:stelaris/feature/sound/card/sound_file_card.dart';

class SoundFileEntryPage extends StatefulWidget {
  const SoundFileEntryPage({super.key});

  @override
  State<SoundFileEntryPage> createState() => _SoundFileEntriesState();
}

class _SoundFileEntriesState extends State<SoundFileEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 2, // Example: 10 items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 400),
              child: const SoundFileCard(),
            ),
          );
        },
      ),
    );
  }
}
