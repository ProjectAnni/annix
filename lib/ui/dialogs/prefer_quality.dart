import 'package:annix/global.dart';
import 'package:annix/services/annil/client.dart';
import 'package:flutter/material.dart';

Future<PreferQuality> showPreferQualityDialog(BuildContext context) async {
  PreferQuality quality = Global.settings.defaultAudioQuality.value;

  await showDialog(
    context: context,
    useRootNavigator: true,
    builder: (context) {
      return Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                RadioListTile<PreferQuality>(
                  title: const Text('Lossless'),
                  value: PreferQuality.Lossless,
                  groupValue: quality,
                  onChanged: (value) {
                    quality = value ?? quality;
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<PreferQuality>(
                  title: const Text('High'),
                  value: PreferQuality.High,
                  groupValue: quality,
                  onChanged: (value) {
                    quality = value ?? quality;
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<PreferQuality>(
                  title: const Text('Medium'),
                  value: PreferQuality.Medium,
                  groupValue: quality,
                  onChanged: (value) {
                    quality = value ?? quality;
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<PreferQuality>(
                  title: const Text('Low'),
                  value: PreferQuality.Low,
                  groupValue: quality,
                  onChanged: (value) {
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
