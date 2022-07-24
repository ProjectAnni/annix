import 'package:annix/controllers/settings_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/pages/settings/settings_log.dart';
import 'package:annix/ui/route/route.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/utils/store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';

typedef WidgetCallback = Widget Function();

class ObxSettingsTileBuilder<T extends RxInterface>
    extends AbstractSettingsTile {
  final Widget Function(T) builder;
  final T value;

  ObxSettingsTileBuilder({required this.builder, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ObxValue<T>(builder, value);
  }
}

class SettingsScreen extends StatelessWidget {
  final bool automaticallyImplyLeading;

  const SettingsScreen({Key? key, this.automaticallyImplyLeading = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.SETTINGS.tr),
        centerTitle: true,
        automaticallyImplyLeading: automaticallyImplyLeading,
      ),
      body: SettingsList(
        lightTheme: SettingsThemeData(
          settingsListBackground: context.colorScheme.background,
        ),
        darkTheme: SettingsThemeData(
          settingsListBackground: context.colorScheme.background,
        ),
        sections: [
          SettingsSection(
            title: Text('Common'),
            tiles: [
              ObxSettingsTileBuilder<RxBool>(
                value: settings.skipCertificateVerification,
                builder: (p) => SettingsTile.switchTile(
                  onToggle: (value) {
                    p.value = value;
                  },
                  initialValue: p.value,
                  leading: Icon(Icons.security_outlined),
                  title: Text(I18n.SETTINGS_SKIP_CERT.tr),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Playback'),
            tiles: [
              ObxSettingsTileBuilder<RxBool>(
                value: settings.useMobileNetwork,
                builder: (p) => SettingsTile.switchTile(
                  onToggle: (value) {
                    p.value = value;
                  },
                  initialValue: p.value,
                  leading: Icon(Icons.mobiledata_off_outlined),
                  title: Text(I18n.SETTINGS_USE_MOBILE_NETWORK.tr),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: Text('Advanced'),
            tiles: <SettingsTile>[
              // view logs
              SettingsTile.navigation(
                leading: Icon(Icons.report_outlined),
                title: Text(I18n.SETTINGS_LOGS.tr),
                description: Text(I18n.SETTINGS_LOGS_DESC.tr),
                onPressed: (context) {
                  AnnixBodyPageRouter.to(() => SettingsLogView());
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
                leading: Icon(Icons.lyrics_outlined),
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
