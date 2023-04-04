import 'package:annix/global.dart';
import 'package:annix/services/annil/annil.dart';
import 'package:annix/services/font.dart';
import 'package:flutter/material.dart';

enum SearchTrackDisplayType {
  /// Display track artist.
  artist,

  /// Display album title.
  albumTitle,

  /// Display track artist and album title.
  artistAndAlbumTitle;

  bool get isThreeLine => this == artistAndAlbumTitle;

  bool get showArtist => this == artist || this == artistAndAlbumTitle;

  bool get showAlbumTitle => this == albumTitle || this == artistAndAlbumTitle;
}

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

  /// Default audio quality
  ///
  /// Default value: Medium
  late ValueNotifier<PreferQuality> defaultAudioQuality;

  /// Custom font path
  ///
  /// Default value: null
  late ValueNotifier<String?> fontPath;

  /// Blur playing page on mobile
  ///
  /// Default value: null
  late ValueNotifier<bool> blurPlayingPage;

  /// Control what to display in search result
  ///
  /// Default value: SearchTrackDisplayType.artist
  late ValueNotifier<SearchTrackDisplayType> searchTrackDisplayType;

  void init() {
    useMobileNetwork = ValueNotifier(
        Global.preferences.getBool('annix_use_mobile_network') ?? true);
    useMobileNetwork.addListener(
        saveChangedVariable('annix_use_mobile_network', useMobileNetwork));

    skipCertificateVerification = ValueNotifier(
        Global.preferences.getBool('annix_skip_certificate_verification') ??
            false);
    skipCertificateVerification.addListener(saveChangedVariable(
        'annix_skip_certificate_verification', skipCertificateVerification));

    autoScaleUI = ValueNotifier(
        Global.preferences.getBool('annix_auto_scale_ui') ?? false);
    autoScaleUI
        .addListener(saveChangedVariable('annix_auto_scale_ui', autoScaleUI));

    mobileShowArtistInBottomPlayer = ValueNotifier(Global.preferences
            .getBool('annix_mobile_show_artist_in_bottom_player') ??
        false);
    mobileShowArtistInBottomPlayer.addListener(saveChangedVariable(
        'annix_mobile_show_artist_in_bottom_player',
        mobileShowArtistInBottomPlayer));

    defaultAudioQuality = ValueNotifier(PreferQuality.values[
        Global.preferences.getInt('annix_default_audio_quality') ??
            PreferQuality.medium.index]);
    defaultAudioQuality.addListener(saveChangedVariable(
        'annix_default_audio_quality', defaultAudioQuality));

    fontPath = ValueNotifier(Global.preferences.getString('annix_font_path'));
    fontPath.addListener(() async {
      await saveChangedVariable('annix_font_path', fontPath)();
      await FontService.load(fontPath.value);
      Global.theme.updateFontFamily();
    });

    blurPlayingPage = ValueNotifier(
        Global.preferences.getBool('annix_enable_blur_playing_page') ?? false);
    blurPlayingPage.addListener(
        saveChangedVariable('annix_enable_blur_playing_page', blurPlayingPage));

    searchTrackDisplayType = ValueNotifier(SearchTrackDisplayType.values[
        Global.preferences.getInt('annix_search_track_display_type') ??
            SearchTrackDisplayType.artist.index]);
    searchTrackDisplayType.addListener(saveChangedVariable(
        'annix_search_track_display_type', searchTrackDisplayType));
  }

  Future<void> Function() saveChangedVariable<T>(
    final String key,
    final ValueNotifier<T> notifier,
  ) {
    return () async {
      final value = notifier.value;
      if (value is String) {
        await Global.preferences.setString(key, value);
      } else if (value is bool) {
        await Global.preferences.setBool(key, value);
      } else if (value is int) {
        await Global.preferences.setInt(key, value);
      } else if (value is double) {
        await Global.preferences.setDouble(key, value);
      } else if (value is Enum) {
        await Global.preferences.setInt(key, value.index);
      } else if (value == null) {
        await Global.preferences.remove(key);
      } else {
        throw Exception('Unsupported type');
      }
    };
  }
}
