import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/settings/settings_log.dart';
import 'package:annix/utils/store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.language),
                title: Text('Language'),
                value: Text('English'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: true,
                leading: Icon(Icons.format_paint),
                title: Text('Enable custom theme'),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Advanced'),
            tiles: <SettingsTile>[
              // view logs
              SettingsTile.navigation(
                leading: Icon(Icons.report_outlined),
                title: Text('Logs'),
                description: Text('View logs'),
                onPressed: (context) {
                  Get.to(() => SettingsLogView());
                },
              ),
              // clear local metadata cache
              SettingsTile.navigation(
                leading: Icon(Icons.featured_play_list_outlined),
                title: Text(I18n.SETTINGS_CLEAR_METADATA_CACHE.tr),
                description: Text(I18n.SETTINGS_CLEAR_METADATA_CACHE_DESC.tr),
                onPressed: (context) async {
                  Get.defaultDialog(
                    title: I18n.PROGRESS.tr,
                    content: CircularProgressIndicator(strokeWidth: 2),
                    barrierDismissible: false,
                    onWillPop: () async => false,
                  );
                  await AnnixStore().clear("album");
                  Get.back();
                },
              ),
              // clear local lyric cache
              SettingsTile.navigation(
                leading: Icon(Icons.featured_play_list_outlined),
                title: Text(I18n.SETTINGS_CLEAR_LYRIC_CACHE.tr),
                description: Text(I18n.SETTINGS_CLEAR_LYRIC_CACHE_DESC.tr),
                onPressed: (context) async {
                  Get.defaultDialog(
                    title: I18n.PROGRESS.tr,
                    content: CircularProgressIndicator(strokeWidth: 2),
                    barrierDismissible: false,
                    onWillPop: () async => false,
                  );
                  await AnnixStore().clear("lyric");
                  Get.back();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
