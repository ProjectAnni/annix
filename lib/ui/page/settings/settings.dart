import 'package:annix/services/settings_controller.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/route/delegate.dart';
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

  const ObxSettingsTileBuilder({
    required this.builder,
    required this.value,
    super.key,
  });

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
            title: const Text('Common'),
            tiles: [
              ObxSettingsTileBuilder<RxBool>(
                value: settings.skipCertificateVerification,
                builder: (p) => SettingsTile.switchTile(
                  onToggle: (value) {
                    p.value = value;
                  },
                  initialValue: p.value,
                  leading: const Icon(Icons.security_outlined),
                  title: Text(I18n.SETTINGS_SKIP_CERT.tr),
                ),
              ),
              ObxSettingsTileBuilder<RxBool>(
                value: settings.autoScaleUI,
                builder: (p) => SettingsTile.switchTile(
                  onToggle: (value) {
                    p.value = value;
                    AnnixRouterDelegate.of(context).popRoute();
                  },
                  initialValue: p.value,
                  leading: const Icon(Icons.smart_screen_outlined),
                  title: Text(I18n.SETTINGS_AUTOSCALE_UI.tr),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Playback'),
            tiles: [
              ObxSettingsTileBuilder<RxBool>(
                value: settings.useMobileNetwork,
                builder: (p) => SettingsTile.switchTile(
                  onToggle: (value) {
                    p.value = value;
                  },
                  initialValue: p.value,
                  leading: const Icon(Icons.mobiledata_off_outlined),
                  title: Text(I18n.SETTINGS_USE_MOBILE_NETWORK.tr),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Advanced'),
            tiles: <SettingsTile>[
              // view logs
              SettingsTile.navigation(
                leading: const Icon(Icons.report_outlined),
                title: Text(I18n.SETTINGS_LOGS.tr),
                description: Text(I18n.SETTINGS_LOGS_DESC.tr),
                onPressed: (context) {
                  AnnixRouterDelegate.of(context).to(name: '/settings/log');
                },
              ),
              // clear local metadata cache
              SettingsTile.navigation(
                leading: const Icon(Icons.featured_play_list_outlined),
                title: Text(I18n.SETTINGS_CLEAR_METADATA_CACHE.tr),
                description: Text(I18n.SETTINGS_CLEAR_METADATA_CACHE_DESC.tr),
                onPressed: (context) async {
                  final delegate = AnnixRouterDelegate.of(context);
                  Get.defaultDialog(
                    title: I18n.PROGRESS.tr,
                    content: const CircularProgressIndicator(strokeWidth: 2),
                    barrierDismissible: false,
                    onWillPop: () async => false,
                  );
                  await AnnixStore().clear("album");
                  delegate.popRoute();
                },
              ),
              // clear local lyric cache
              SettingsTile.navigation(
                leading: const Icon(Icons.lyrics_outlined),
                title: Text(I18n.SETTINGS_CLEAR_LYRIC_CACHE.tr),
                description: Text(I18n.SETTINGS_CLEAR_LYRIC_CACHE_DESC.tr),
                onPressed: (context) {
                  final navigator = Navigator.of(context, rootNavigator: true);
                  showDialog(
                    context: context,
                    useRootNavigator: true,
                    builder: (context) => SimpleDialog(
                      title: Text(I18n.PROGRESS.tr),
                      children: const [
                        Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ),
                    barrierDismissible: false,
                  );
                  AnnixStore().clear("lyric").then((_) => navigator.pop());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
