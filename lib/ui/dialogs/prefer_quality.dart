import 'package:annix/global.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:flutter/material.dart';

Future<PreferQuality> showPreferQualityDialog(final BuildContext context) async {
  PreferQuality quality = Global.settings.defaultAudioQuality.value;

  await showDialog(
    context: context,
    useRootNavigator: true,
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
