import 'package:annix/providers.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<PreferQuality> showPreferQualityDialog(
    final BuildContext context, final WidgetRef ref) async {
  PreferQuality quality = ref.read(settingsProvider).defaultAudioQuality.value;

  await showDialog(
    context: context,
    builder: (final context) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                RadioListTile<PreferQuality>(
                  title: const Text('Lossless'),
                  value: PreferQuality.lossless,
                  groupValue: quality,
                  onChanged: (final value) {
                    quality = value ?? quality;
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<PreferQuality>(
                  title: const Text('High'),
                  value: PreferQuality.high,
                  groupValue: quality,
                  onChanged: (final value) {
                    quality = value ?? quality;
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<PreferQuality>(
                  title: const Text('Medium'),
                  value: PreferQuality.medium,
                  groupValue: quality,
                  onChanged: (final value) {
                    quality = value ?? quality;
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<PreferQuality>(
                  title: const Text('Low'),
                  value: PreferQuality.low,
                  groupValue: quality,
                  onChanged: (final value) {
                    quality = value ?? quality;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return quality;
}
