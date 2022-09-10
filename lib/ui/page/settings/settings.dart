import 'package:annix/global.dart';
import 'package:annix/i18n/i18n.dart';
import 'package:annix/ui/dialogs/loading.dart';
import 'package:annix/ui/route/delegate.dart';
import 'package:annix/utils/context_extension.dart';
import 'package:annix/utils/store.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

typedef WidgetCallback = Widget Function();

class SettingsTileBuilder<T> extends AbstractSettingsTile {
  final Widget Function(BuildContext, T, Widget?) builder;
  final ValueNotifier<T> value;
  final Widget? child;

  const SettingsTileBuilder({
    required this.builder,
    required this.value,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
      valueListenable: value,
      builder: builder,
      child: child,
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final bool automaticallyImplyLeading;

  const SettingsScreen({Key? key, this.automaticallyImplyLeading = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = Global.settings;

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
              SettingsTileBuilder<bool>(
                value: settings.skipCertificateVerification,
                builder: (context, p, child) => SettingsTile.switchTile(
                  onToggle: (value) {
                    settings.skipCertificateVerification.value = value;
                  },
                  initialValue: p,
                  leading: const Icon(Icons.security_outlined),
                  title: Text(I18n.SETTINGS_SKIP_CERT.tr),
                ),
              ),
              SettingsTileBuilder<bool>(
                value: settings.autoScaleUI,
                builder: (context, p, _) => SettingsTile.switchTile(
                  onToggle: (value) {
                    settings.autoScaleUI.value = value;
                    AnnixRouterDelegate.of(context).popRoute();
                  },
                  initialValue: p,
                  leading: const Icon(Icons.smart_screen_outlined),
                  title: Text(I18n.SETTINGS_AUTOSCALE_UI.tr),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('UI'),
            tiles: [
              SettingsTileBuilder<bool>(
                value: settings.mobileShowArtistInBottomPlayer,
                builder: (context, p, _) => SettingsTile.switchTile(
                  onToggle: (value) {
                    settings.mobileShowArtistInBottomPlayer.value = value;
                  },
                  initialValue: p,
                  leading: const Icon(Icons.person_outline),
                  title: const Text("Show artist in bottom player"),
                ),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('Playback'),
            tiles: [
              SettingsTileBuilder<bool>(
                value: settings.useMobileNetwork,
                builder: (context, p, _) => SettingsTile.switchTile(
                  onToggle: (value) {
                    settings.useMobileNetwork.value = value;
                  },
                  initialValue: p,
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
                  showLoadingDialog(context);
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
