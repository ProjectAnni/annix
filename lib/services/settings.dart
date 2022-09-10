import 'package:annix/global.dart';
import 'package:flutter/material.dart';

class SettingsController {
  /// Download audio files using mobile network
  ///
  /// Default: true
  late ValueNotifier<bool> useMobileNetwork;

  /// Whether to skip certification check
  ///
  /// Default value: false
  late ValueNotifier<bool> skipCertificateVerification;

  /// Whether to enable auto scalable UI
  ///
  /// Default value: false
  late ValueNotifier<bool> autoScaleUI;

  /// [Mobile] Whether to display track artist in bottom player
  ///
  /// Default value: false
  late ValueNotifier<bool> mobileShowArtistInBottomPlayer;

  void init() {
    useMobileNetwork = ValueNotifier(
        Global.preferences.getBool("annix_use_mobile_network") ?? true);
    useMobileNetwork.addListener(
        saveChangedVariable("annix_use_mobile_network", useMobileNetwork));

    skipCertificateVerification = ValueNotifier(
        Global.preferences.getBool("annix_skip_certificate_verification") ??
            false);
    skipCertificateVerification.addListener(saveChangedVariable(
        "annix_skip_certificate_verification", skipCertificateVerification));

    autoScaleUI = ValueNotifier(
        Global.preferences.getBool("annix_auto_scale_ui") ?? false);
    autoScaleUI
        .addListener(saveChangedVariable("annix_auto_scale_ui", autoScaleUI));

    mobileShowArtistInBottomPlayer = ValueNotifier(Global.preferences
            .getBool("annix_mobile_show_artist_in_bottom_player") ??
        false);
    mobileShowArtistInBottomPlayer.addListener(saveChangedVariable(
        "annix_mobile_show_artist_in_bottom_player",
        mobileShowArtistInBottomPlayer));
  }

  void Function() saveChangedVariable<T>(
    String key,
    ValueNotifier<T> notifier,
  ) {
    return () {
      final value = notifier.value;
      if (value is String) {
        Global.preferences.setString(key, value);
      } else if (value is bool) {
        Global.preferences.setBool(key, value);
      } else if (value is int) {
        Global.preferences.setInt(key, value);
      } else if (value is double) {
        Global.preferences.setDouble(key, value);
      } else {
        throw Exception("Unsupported type");
      }
    };
  }
}
