import 'package:annix/pages/settings/settings_log.dart';
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
            title: Text('Development'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: Icon(Icons.report_outlined),
                title: Text('Logs'),
                description: Text('View logs'),
                onPressed: (context) {
                  Get.to(() => SettingsLogView());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
