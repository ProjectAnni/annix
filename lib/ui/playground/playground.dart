import 'package:annix/ui/playground/material_you_player_page.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlaygroundPage extends ConsumerWidget {
  const PlaygroundPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Playground'),
        backgroundColor: colorScheme.surfaceContainerLow,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_filled),
          label: const Text('Open Full Player'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const MaterialYouPlayerPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
