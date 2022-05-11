import 'package:f_logs/f_logs.dart';
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
                onPressed: (context) async {
                  final logs = await FLog.getAllLogs();
                  if (logs.isNotEmpty) {
                    Get.dialog(
                      AlertDialog(
                        title: Text('Log'),
                        content: Text(logs[0].text ?? ""),
                        actions: [
                          TextButton(
                            child: Text("Close"),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
